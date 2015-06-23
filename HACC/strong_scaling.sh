#!/bin/bash

function Usage {
	echo "$0 -s nstart -e nend [-r ex_name] [-p prog_name] [-i]"
	echo " -s: nstart"
	echo " -e: nend"
	echo " -r: name run"
	echo " -p: program"
	echo " -i: use instrumented version"
	exit 1
}

SCRIPT_FILE="./testing.txt"
WD="/home/pptm71/pptm71014/HACC/work"
SCRIPTS="$WD/scripts"
tracescript="$SCRIPTS/trace.sh"
INPUT="indat.strong"

nstart=0
nend=0
ex_name=`date -I`
mkdir -p "$WD/runs/${ex_name}_strong"

prog="/home/pptm71/pptm71014/HACC/stable/hacc_tpm_noThreads"
prog_name="HACC"
echo "reading opts"
while getopts "hs:e:r:p" o; do
	case "${o}" in
		h)
			Usage
			;;
		s)
			nstart=$OPTARG
			nend=$nstart
			;;
		e)
			nend=$OPTARG
			;;
		p)
			prog_name=$OPTARG
			;;
		:)
			Usage
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			Usage
			;;
	esac
done

test $nstart == 0 && exit 1
test $nend == 0 && exit 1
x=1
y=1
z=1



while [ $nstart -le $nend  ]; do
	
	
	##DISTRIBUTING WORK??
	while [ $(( $x*$y*$z)) -ne $nstart ];
	do
		if [ $nstart -gt 1 ]; then
		    if [ $x -eq $y ] && [ $y -eq $z ]; then
		            x=$(( $x*2 ))
		    elif [ $y -eq $z ]; then
		            y=$(( $y*2 ))
		    else
		            z=$(( $z*2 ))
		    fi
		fi
	done
	
	echo "#!/bin/bash"						>  $SCRIPT_FILE
	echo "#BSUB -n $nstart"						>> $SCRIPT_FILE
	echo "#BSUB -J \"${prog_name}_${nstart}x1x1\""			>> $SCRIPT_FILE
	echo "#BSUB -o output_%J.out"					>> $SCRIPT_FILE
	echo "#BSUB -o \"${prog_name}_${nstart}x1x1\""	
	echo "#BSUB -e error_%J.err"					>> $SCRIPT_FILE
	echo "#BSUB -W 10:00"						>> $SCRIPT_FILE
	echo "#BSUB -cwd $WD/runs/${ex_name}_strong/%J_${nstart}x1x1"	>> $SCRIPT_FILE
	echo "#BSUB -R \"span[ptile=8]\""				>> $SCRIPT_FILE

	echo "module load openmpi mkl"					>> $SCRIPT_FILE
	
	echo "export OMP_THREAD_LIMIT=1"				>> $SCRIPT_FILE
	echo "export OMP_NUM_THREADS=1"					>> $SCRIPT_FILE
	echo "export MKL_NUM_THREADS=1"					>> $SCRIPT_FILE
	echo "export KMP_STACKSIZE=64m"					>> $SCRIPT_FILE
	echo "ulimit -s unlimited"					>> $SCRIPT_FILE
	echo "ulimit -c unlimited"					>> $SCRIPT_FILE
	
	echo "/usr/bin/time mpirun $prog ${WD}/$INPUT ${WD}/cmbM000.tf m000 INIT ALL_TO_ALL -w -R -N 512 -a ${WD}/final -f ${WD}/refresh -t ${nstart}x1x1"				>> $SCRIPT_FILE

	jobID=`bsub < $SCRIPT_FILE`
	echo $jobID

######################### DISTRIBUTING WORK ###############################

	echo "#!/bin/bash"						>  $SCRIPT_FILE
	echo "#BSUB -n $nstart"						>> $SCRIPT_FILE
	echo "#BSUB -J \"${prog_name}_${x}x${y}x${z}\""			>> $SCRIPT_FILE
	echo "#BSUB -o output_%J.out"					>> $SCRIPT_FILE
	echo "#BSUB -o \"${prog_name}_${x}x${y}x${z}\""
	echo "#BSUB -e error_%J.err"					>> $SCRIPT_FILE
	echo "#BSUB -W 10:00"						>> $SCRIPT_FILE
	echo "#BSUB -cwd ${WD}/runs/${ex_name}_strong/%J_${x}x${y}x${z}">> $SCRIPT_FILE
	echo "#BSUB -R \"span[ptile=8]\""				>> $SCRIPT_FILE

	echo "module load openmpi mkl"					>> $SCRIPT_FILE
	echo "export OMP_THREAD_LIMIT=1"				>> $SCRIPT_FILE
	echo "export OMP_NUM_THREADS=1"					>> $SCRIPT_FILE
	echo "export MKL_NUM_THREADS=1"					>> $SCRIPT_FILE
	echo "export KMP_STACKSIZE=64m"					>> $SCRIPT_FILE
	echo "ulimit -s unlimited"					>> $SCRIPT_FILE
	echo "ulimit -c unlimited"					>> $SCRIPT_FILE

	echo "/usr/bin/time mpirun $prog ${WD}/$INPUT ${WD}/cmbM000.tf m000 INIT ALL_TO_ALL -w -R -N 512 -a ${WD}/final -f ${WD}/refresh -t ${x}x${y}x${z}"					>> $SCRIPT_FILE

	jobID=`bsub < $SCRIPT_FILE`
	echo $jobID


	nstart=$(( $nstart*2 ))
done
