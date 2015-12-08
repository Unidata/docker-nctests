#!/bin/bash
#
# Utility script to retag docker images to normal
# nomenclature, instead of the form used by docker-compose.
#

set -e
set -x

docker tag dockernctests_base      unidata/nctests:base
docker tag dockernctests_serial    unidata/nctests:serial
docker tag dockernctests_openmpi   unidata/nctests:openmpi
docker tag dockernctests_mpich     unidata/nctests:mpich

docker tag dockernctests_base32    unidata/nctests:base32
docker tag dockernctests_serial32  unidata/nctests:serial32
docker tag dockernctests_openmpi32 unidata/nctests:openmpi32
docker tag dockernctests_mpich32   unidata/nctests:mpich32
