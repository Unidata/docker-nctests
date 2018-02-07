#!/bin/bash

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

if [ "x$HELP" != "x" ]; then
    cat README.md
    echo ""
    cat VERSION.md
    echo ""
    exit
fi

if [ "x$CMD" = "xhelp" ]; then
    cat README.md
    echo ""
    cat VERSION.md
    exit
fi

if [ "x$VERSION" != "x" ]; then
    cat VERSION.md
    echo ""
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
# Print out version.
###
cat VERSION.md

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
    git clone /netcdf-c ${HOME}/netcdf-c
else
    echo "Using remote netcdf-c repository"
    git clone http://www.github.com/Unidata/netcdf-c --single-branch --branch $CBRANCH --depth=1 $CBRANCH
    mv $CBRANCH netcdf-c
fi

if [ "x$RUNNCO" == "xTRUE" ]; then
    if [ -d "/nco" ]; then
        echo "Using local NCO repository"
        git clone /nco ${HOME}/nco
    else
        echo "Using remote NCO repository"
        git clone https://github.com/nco/nco.git --single-branch --branch $NCOBRANCH --depth=1 $NCOBRANCH
        mv $NCOBRANCH nco
    fi
else
    echo "Skipping NCO"
fi

###
# Initalize some variables
# for looping/performing repeated tests.
###
CCOUNT=1
FCOUNT=1
CXXCOUNT=1
PCOUNT=1
NCOCOUNT=1

###
# Build & test netcdf-c, then install it so it
# can be used by the other projects.
###

cd ${HOME}


# CREPS is defined as an environmental variable.



while [[ $CCOUNT -le $CREPS ]]; do

    if [ "x$USECMAKE" = "xTRUE" ]; then

        if [ "x$RUNC" == "xTRUE" ]; then
            echo "[$CCOUNT | $CREPS] Testing netCDF-C - CMAKE"
        else
            echo "[$CCOUNT | $CREPS] Installing netCDF-C - CMAKE"
        fi
        echo "----------------------------------"
        sleep 2
        mkdir -p build-netcdf-c
        cd build-netcdf-c
        cmake ${HOME}/netcdf-c -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_HDF4=ON -DENABLE_EXTRA_TESTS=ON -DENABLE_MMAP=ON -DBUILDNAME_PREFIX="docker$BITNESS-$USE_CC" -DBUILDNAME_SUFFIX="$CBRANCH" -DCMAKE_C_COMPILER=$USE_CC $COPTS ; CHECKERR
        make clean

        if [ "x$RUNC" == "xTRUE" ]; then

            if [ "x$USEDASH" == "xTRUE" ]; then
                ctest -D Experimental -j $TESTPROC ; CHECKERR
                if [ "x$USE_VALGRIND" == "xTRUE" ]; then
                    make ExperimentalMemCheck
                    make ExperimentalSubmit
                fi
            else
                make -j 4 && ctest -j $TESTPROC ; CHECKERR
                if [ "x$USE_VALGRIND" == "xTRUE" ]; then
                    make ExperimentalMemCheck
                fi
            fi



        else
            make -j 4 ; CHECKERR
        fi
        cd ${HOME}
        echo ""
    fi

    if [ "x$USEAC" = "xTRUE" ]; then

        if [ "x$RUNC" == "xTRUE" ]; then
            echo "[$CCOUNT | $CREPS] Testing netCDF-C - AutoConf"
        else
            echo "[$CCOUNT | $CREPS] Installing netCDF-C - AutoConf"
        fi

        echo "----------------------------------"

        sleep 2
        cd netcdf-c
        if [ ! -f "configure" ]; then
            autoreconf -if
        fi
        CC=$USE_CC ./configure --prefix=/usr --enable-hdf4 --enable-extra-tests --enable-mmap "$AC_COPTS"
        make clean
        make -j 4 ; CHECKERR
        if [ "x$RUNC" == "xTRUE" ]; then
            make check TESTS="" -j 4 ; CHECKERR
            make check -j $TESTPROC ; CHECKERR

            if [ "x$DISTCHECK" == "xTRUE" ]; then
                DISTCHECK_CONFIGURE_FLAGS="--enable-hdf4 --enable-extra-tests --enable-mmap $AC_COPTS" make distcheck ; CHECKERR
            fi

        fi
        cd ${HOME}
        echo ""
    fi

    CCOUNT=$[$CCOUNT+1]
done


if [ "x$USECMAKE" = "xTRUE" ]; then
    cd build-netcdf-c
    sudo make install
elif [ "x$USEAC" = "xTRUE" ]; then
    cd netcdf-c
    sudo make install
fi

cd ${HOME}

###
# Build & test NCO
###
if [ "x$RUNNCO" == "xTRUE" ]; then

    echo "[$NCOCOUNT | $NCOREPS] Testing NCO"
    cd ${HOME}/nco
    CC=$USE_CC ./configure
    make -j 8
    sudo make install
    cd ${HOME}
    ncgen -3 in.cdl -o in.nc
    ncap2 -C -v -O -s 'n2=three_dmn_var_dbl;' in.nc foo.nc
fi
