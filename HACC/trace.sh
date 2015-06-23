#!/bin/bash

if [ ! -z "${TMPDIR}" ]; then
        export TMPDIR=$TMPDIR/extrae
        mkdir -p $TMPDIR
fi

#export EXTRAE_HOME=/apps/CEPBATOOLS/extrae/latest/openmpi/64
export EXTRAE_CONFIG_FILE=/home/pptm71/pptm71014/HACC/work/extrae.xml

#export LD_PRELOAD=$EXTRAE_HOME/lib/libompitrace.so
export LD_PRELOAD=$EXTRAE_HOME/lib/libmpitrace.so

$@
