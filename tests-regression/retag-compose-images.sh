#!/bin/bash
#
# Utility script to retag docker images to normal
# nomenclature, instead of the form used by docker-compose.
#

set -e

RETAG() {

    echo "Retagging $1 to $2"
    docker tag $1 $2
    docker rmi -f $1

}



RETAG dockernctests_base      unidata/nctests:base
RETAG dockernctests_serial    unidata/nctests:serial
RETAG dockernctests_openmpi   unidata/nctests:openmpi
RETAG dockernctests_mpich     unidata/nctests:mpich

RETAG dockernctests_base32    unidata/nctests:base32
RETAG dockernctests_serial32  unidata/nctests:serial32
RETAG dockernctests_openmpi32 unidata/nctests:openmpi32
RETAG dockernctests_mpich32   unidata/nctests:mpich32
