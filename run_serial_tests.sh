#!/bin/bash

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

if [ "x$CMD" = "xhelp" ]; then
    cat DOCKER_README.md
    exit
fi

###
# Check out all the projects.
#
# If the project file has been mapped to a directory
# on the root of the docker image filesystem, use
# that instead.  If this is the case, we assume that
# it is already on the branch we want.  The branch
# environmental variable will need to be specified still,
# if we want it to show up in the build name on the
# appropriate dashboard.
#
# Check out the branch
# specified by "CBRANCH", "FBRANCH", "CXXBRANCH"
###

if [ -d "/netcdf-c" ]; then
    echo "Using local netcdf-c repository"
    git clone /netcdf-c /root/netcdf-c
else
    echo "Using remote netcdf-c repository"
    git clone http://www.github.com/Unidata/netcdf-c --single-branch $CBRANCH --depth=1
    mv $CBRANCH netcdf-c
fi

if [ "x$RUNF" == "xTRUE" ]; then

    if [ -d "/netcdf-fortran" ]; then
        echo "Using local netcdf-fortran repository"
        git clone /netcdf-fortran /root/netcdf-fortran
    else
        echo "Using remote netcdf-fortran repository"
        git clone http://www.github.com/Unidata/netcdf-fortran --single-branch $FBRANCH --depth=1
        mv $FBRANCH netcdf-fortran
    fi
else
    echo "Skipping Fortran"
fi


if [ "x$RUNCXX" == "xTRUE" ]; then

    if [ -d "/netcdf-cxx4" ]; then
        echo "Using local netcdf-cxx4 repository"
        git clone /netcdf-cxx4 /root/netcdf-cxx4
    else
        echo "Using remote netcdf-cxx4 repository"
        git clone http://www.github.com/Unidata/netcdf-cxx4 --single-branch $CXXBRANCH --depth=1
        mv $CXXBRANCH netcdf-cxx4
    fi
else
    echo "Skipping CXX"
fi

###
# Build & test netcdf-c, then install it so it
# can be used by the other projects.
###

cd /root

mkdir build-netcdf-c
cd build-netcdf-c
cmake /root/netcdf-c -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_HDF4=ON -DENABLE_EXTRA_TESTS=ON -DENABLE_MMAP=ON -DBUILDNAME_PREFIX="docker$BITNESS" -DBUILDNAME_SUFFIX="$CBRANCH" $COPTS

if [ "x$USEDASH" == "xTRUE" ]; then
    make Experimental
else
    make -j 4 && make test
fi

make install


###
# Build & test netcdf-fortran
###

if [ "x$RUNF" == "xTRUE" ]; then
    cd /root
    mkdir build-netcdf-fortran
    cd build-netcdf-fortran
    cmake /root/netcdf-fortran -DBUILDNAME_PREFIX="docker$BITNESS" -DBUILDNAME_SUFFIX="$FBRANCH" $FOPTS
    if [ "x$USEDASH" == "xTRUE" ]; then
        make Experimental
    else
        make -j 4 && make test
    fi
fi

###
# Build & test netcdf-cxx4.
###

if [ "x$RUNCXX" == "xTRUE" ]; then

    cd /root
    mkdir build-netcdf-cxx4
    cd build-netcdf-cxx4
    cmake /root/netcdf-cxx4 -DBUILDNAME_PREFIX="docker$BITNESS" -DBUILDNAME_SUFFIX="$CXXBRANCH" $CXXOPTS
    if [ "x$USEDASH" == "xTRUE" ]; then
        make Experimental
    else
        make -j 4 && make test
    fi

fi
