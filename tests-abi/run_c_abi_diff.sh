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

TDIR="$OLDVER"

git clone -b $OLDVER --depth=1 https://github.com/Unidata/netcdf-c $TDIR
pushd $TDIR
mkdir build && cd build
cmake .. -DCMAKE_C_FLAGS="-g -Og" -DENABLE_TESTS=OFF
make -j 4

if [ -f liblib/libnetcdf.so ]; then
    abi-dumper liblib/libnetcdf.so -o /output/ABI-C-$NEWVER.dump -lver $NEWVER
else 
    abi-dumper libnetcdf.so -o /output/ABI-C-$NEWVER.dump -lver $NEWVER
fi
git reset --hard
popd

TDIR="$NEWVER"
git clone -b $NEWVER --depth=1 https://github.com/Unidata/netcdf-c $TDIR
pushd $TDIR
mkdir build && cd build
cmake .. -DCMAKE_C_FLAGS="-g -Og" -DENABLE_TESTS=OFF
make -j 4
if [ -f liblib/libnetcdf.so ]; then
    abi-dumper liblib/libnetcdf.so -o /output/ABI-C-$NEWVER.dump -lver $NEWVER
else 
    abi-dumper libnetcdf.so -o /output/ABI-C-$NEWVER.dump -lver $NEWVER
fi
popd

cd /output
abi-compliance-checker -l libnetcdf -old ABI-C-$OLDVER.dump -new ABI-C-$NEWVER.dump

echo "Finished."
