#!/bin/bash
#
# Utility script to retag docker images to normal
# nomenclature, instead of the form used by docker-compose.
#

set -e

RETAG() {

    echo "Retagging $1 to $2"
    docker tag -f $1 $2
    docker rmi -f $1

}



RETAG testsregression_base      unidata/nctests:base
RETAG testsregression_serial    unidata/nctests:serial
RETAG testsregression_openmpi   unidata/nctests:openmpi
RETAG testsregression_mpich     unidata/nctests:mpich

RETAG testsregression_base32    unidata/nctests:base32
RETAG testsregression_serial32  unidata/nctests:serial32
RETAG testsregression_openmpi32 unidata/nctests:openmpi32
RETAG testsregression_mpich32   unidata/nctests:mpich32
