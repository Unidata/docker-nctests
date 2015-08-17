#!/bin/bash

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

if [ "x$CMD" = "xhelp" ]; then
    cat DOCKER_README.md
    exit
fi

CHECKERR() {

    RES=$?

    if [[ $RES -ne 0 ]]; then
        echo "Error Caught: $RES"
        exit $RES
    fi

}

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
    git clone http://www.github.com/Unidata/netcdf-c --single-branch --branch $CBRANCH --depth=1 $CBRANCH
    mv $CBRANCH netcdf-c
fi

if [ "x$RUNF" == "xTRUE" ]; then

    if [ -d "/netcdf-fortran" ]; then
        echo "Using local netcdf-fortran repository"
        git clone /netcdf-fortran /root/netcdf-fortran
    else
        echo "Using remote netcdf-fortran repository"
        git clone http://www.github.com/Unidata/netcdf-fortran --single-branch --branch $FBRANCH --depth=1 $FBRANCH
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
        git clone http://www.github.com/Unidata/netcdf-cxx4 --single-branch --branch $CXXBRANCH --depth=1 $CXXBRANCH
        mv $CXXBRANCH netcdf-cxx4
    fi
else
    echo "Skipping CXX"
fi

###
# Initalize some variables
# for looping/performing repeated tests.
###
CCOUNT=1
FCOUNT=1
CXXCOUNT=1

###
# Build & test netcdf-c, then install it so it
# can be used by the other projects.
###

cd /root


# CREPS is defined as an environmental variable.

while [[ $CCOUNT -le $CREPS ]]; do

    if [ "x$USECMAKE" = "xTRUE" ]; then

        echo "[$CCOUNT | $CREPS] Testing netCDF-C - CMAKE"
        echo "----------------------------------"
        sleep 2
        mkdir -p build-netcdf-c
        cd build-netcdf-c

        cmake /root/netcdf-c -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_HDF4=ON -DENABLE_EXTRA_TESTS=ON -DENABLE_MMAP=ON -DBUILDNAME_PREFIX="docker$BITNESS" -DBUILDNAME_SUFFIX="$CBRANCH" $COPTS
        make clean
        if [ "x$USEDASH" == "xTRUE" ]; then
            make Experimental
        else
            make -j 4 && make test
        fi
        cd /root
        echo ""
    fi

    if [ "x$USEAC" = "xTRUE" ]; then
        echo "[$CCOUNT | $CREPS] Testing netCDF-C - AutoConf"
        echo "----------------------------------"
        sleep 2
        cd netcdf-c
        autoreconf -if
        ./configure --enable-hdf4 --enable-extra-tests --enable-mmap "$AC_COPTS"
        make clean
        make -j 4
        make check TESTS="" -j 4
        make check
        cd /root
        echo ""
    fi

    CCOUNT=$[$CCOUNT+1]
done


if [ "x$USECDASH" = "xTRUE" ]; then
    cd build-netcdf-c
    make install
elif [ "x$USEAC" = "xTRUE" ]; then
    cd netcdf-c
    make install
fi

cd /root

###
# Build & test netcdf-fortran
###

if [ "x$RUNF" == "xTRUE" ]; then


    while [[ $FCOUNT -le $FREPS ]]; do

        if [ "x$USECMAKE" = "xTRUE" ]; then
            echo "[$FCOUNT | $FREPS] Testing netCDF-Fortran - CMAKE"
            echo "----------------------------------"
            cd /root
            mkdir -p build-netcdf-fortran
            cd build-netcdf-fortran
            cmake /root/netcdf-fortran -DBUILDNAME_PREFIX="docker$BITNESS" -DBUILDNAME_SUFFIX="$FBRANCH" $FOPTS
            if [ "x$USEDASH" == "xTRUE" ]; then
                make Experimental ; CHECKERR
            else
                make -j 4 && make test

            fi
            make clean
            cd /root
            echo ""
        fi

        if [ "x$USEAC" = "xTRUE" ]; then
            echo "[$FCOUNT | $FREPS] Testing netCDF-Fortran - AutoConf"
            echo "----------------------------------"
            sleep 2
            cd netcdf-fortran
            autoreconf -if
            ./configure "$AC_FOPTS"
            make -j 4 ; CHECKERR
            make check TESTS="" -j 4
            make check ; CHECKERR
            make clean
            cd /root
            echo ""
        fi

        FCOUNT=$[$FCOUNT+1]
    done
fi

###
# Build & test netcdf-cxx4.
###

if [ "x$RUNCXX" == "xTRUE" ]; then


    while [[ $CXXCOUNT -le $CXXREPS ]]; do

        if [ "x$USECMAKE" = "xTRUE" ]; then
            echo "[$CXXCOUNT | $CXXREPS] Testing netCDF-CXX4 - CMAKE"
            echo "----------------------------------"

            mkdir -p build-netcdf-cxx4
            cd build-netcdf-cxx4
            cmake /root/netcdf-cxx4 -DBUILDNAME_PREFIX="docker$BITNESS" -DBUILDNAME_SUFFIX="$CXXBRANCH" $CXXOPTS
            if [ "x$USEDASH" == "xTRUE" ]; then
                make Experimental
            else
                make -j 4 && make test
            fi
            make clean
            cd /root
            echo ""
        fi

        if [ "x$USEAC" = "xTRUE" ]; then
            echo "[$CXXCOUNT | $CXXREPS] Testing netCDF-CXX4 - AutoConf"
            echo "----------------------------------"
            sleep 2
            cd netcdf-fortran
            autoreconf -if
            ./configure "$AC_CXXOPTS"
            make -j 4
            make check TESTS="" -j 4
            make check ; CHECKERR
            make clean
            cd /root
            echo ""
        fi

        CXXCOUNT=$[CXXCOUNT+1]

    done

fi
