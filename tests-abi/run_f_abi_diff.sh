#!/bin/bash
#####
# Script to run abi comparison tools.
#####

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

if [ "x$HELP" != "x" ]; then
    cat README.md
    exit
fi

if [ ! -d "/output" ]; then
    cat README.md
    exit
fi

if [ "x$OLDVER" == "x" ]; then
    cat README.md
    exit
fi

if [ "x$NEWVER" == "x" ]; then
    cat README.md
    exit
fi



TOPDIR=$(pwd)
OLDBUILD="build-$OLDVER"
NEWBUILD="build-$NEWVER"

##
# First install libnetcdf-c
##

export NCVER=v4.9.3
git clone https://github.com/Unidata/netcdf-c && cd netcdf-c && git checkout ${NCVER} && mkdir build && cd build && cmake .. -DENABLE_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr && make -j 100 && sudo make install
##
# End install netCDF-C
##

TDIR="netcdf-fortran"

git clone http://github.com/Unidata/netcdf-fortran $TDIR
cd $TDIR
mkdir $OLDBUILD
mkdir $NEWBUILD

pushd $OLDBUILD
git checkout $OLDVER
cmake .. -DCMAKE_Fortran_FLAGS="-g -Og" -DENABLE_TESTS=OFF
make -j 4
abi-dumper fortran/libnetcdff.so -o /output/ABI-F-$OLDVER.dump -lver $OLDVER
git reset --hard
popd

pushd $NEWBUILD
git checkout $NEWVER
cmake .. -DCMAKE_Fortran_FLAGS="-g -Og" -DENABLE_TESTS=OFF
make -j 4
abi-dumper fortran/libnetcdff.so -o /output/ABI-F-$NEWVER.dump -lver $NEWVER
popd

cd /output
abi-compliance-checker -l libnetcdff -old ABI-F-$OLDVER.dump -new ABI-F-$NEWVER.dump

echo "Finished."
