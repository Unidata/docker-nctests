#!/bin/bash

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

export OMPI_MPICC=$USE_CC
export OMPI_CC=$USE_CC
export OMPI_CXX=$USE_CXX

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
    echo ""
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
    if [ "x$USE_LOCAL_CP" == "xTRUE" ]; then
        cp -R /netcdf-c ${HOME}
    else
        git clone /netcdf-c ${HOME}/netcdf-c
    fi
else
    echo "Using remote netcdf-c repository"
    git clone http://www.github.com/Unidata/netcdf-c --single-branch --branch $CBRANCH --depth=1 $CBRANCH
    mv $CBRANCH netcdf-c
fi

if [ "x$RUNF" == "xTRUE" ]; then
    if [ -d "/netcdf-fortran" ]; then
        echo "Using local netcdf-fortran repository"
        if [ "x$USE_LOCAL_CP" != "xTRUE" ]; then
            cp -R /netcdf-fortran ${HOME}
        else
            git clone /netcdf-fortran ${HOME}/netcdf-fortran
        fi
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
        if [ "x$USE_LOCAL_CP" == "xTRUE" ]; then
            cp -R /netcdf-cxx4 ${HOME}
        else
            git clone /netcdf-cxx4 ${HOME}/netcdf-cxx4
        fi

        else
        echo "Using remote netcdf-cxx4 repository"
        git clone http://www.github.com/Unidata/netcdf-cxx4 --single-branch --branch $CXXBRANCH --depth=1 $CXXBRANCH
        mv $CXXBRANCH netcdf-cxx4
        cd ${HOME}
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

cd ${HOME}

# CREPS is defined as an environmental variable.

while [[ $CCOUNT -le $CREPS ]]; do

    if [ "x$USECMAKE" = "xTRUE" ]; then

        echo "[$CCOUNT | $CREPS] Testing netCDF-C - CMAKE"
        echo "----------------------------------"
        sleep 2
        mkdir -p build-netcdf-c
        cd build-netcdf-c
        cmake ${HOME}/netcdf-c -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_HDF4=ON -DENABLE_EXTRA_TESTS=ON -DENABLE_MMAP=ON -DBUILDNAME_PREFIX="docker$BITNESS-parallel$PARTYPE" -DBUILDNAME_SUFFIX="$CBRANCH" -DCMAKE_C_COMPILER=$(which mpicc) -DENABLE_PNETCDF=ON -DENABLE_PARALLEL_TESTS=ON $COPTS

        if [ "x$RUNC" == "xTRUE" ]; then
            if [ "x$USEDASH" == "xTRUE" ]; then
		ctest -D Experimental -j $TESTPROC ; CHECKERR
            else
                make -j 4 && ctest -j $TESTPROC ; CHECKERR
            fi
        else
            make -j 4 ; CHECKERR
        fi
        cd ${HOME}
        echo ""
    fi

    if [ "x$USEAC" = "xTRUE" ]; then
        echo "[$CCOUNT | $CREPS] Testing netCDF-C - AutoConf"
        echo "----------------------------------"
        sleep 2
        cd netcdf-c
        if [ ! -f "configure" ]; then
            autoreconf -if
        fi
        CC=`which mpicc` ./configure --enable-hdf4 --enable-extra-tests --enable-mmap --enable-pnetcdf --enable-parallel-tests --prefix=/usr "$AC_COPTS"
        make clean
        make -j 4 ; CHECKERR
        if [ "x$RUNC" == "xTRUE" ]; then
            make check TESTS="" -j 4 ; CHECKERR
            make check -j $TESTPROC ; CHECKERR

            if [ "x$DISTCHECK" == "xTRUE" ]; then
                CC=$(which mpicc) DISTCHECK_CONFIGURE_FLAGS="--enable-hdf4 --enable-extra-tests --enable-mmap --enable-pnetcdf --enable-parallel-tests $AC_COPTS" make distcheck ; CHECKERR
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

sudo ldconfig

###
# Build & test netcdf-fortran
###


if [ "x$RUNF" == "xTRUE" ]; then
    while [[ $FCOUNT -le $FREPS ]]; do

        if [ "x$USECMAKE" = "xTRUE" ]; then
            echo "[$FCOUNT | $FREPS] Testing netCDF-Fortran - CMAKE"
            echo "----------------------------------"
            cd ${HOME}
            mkdir -p build-netcdf-fortran
            cd build-netcdf-fortran
            cmake ${HOME}/netcdf-fortran -DBUILDNAME_PREFIX="docker$BITNESS-parallel$PARTYPE" -DBUILDNAME_SUFFIX="$FBRANCH" -DTEST_PARALLEL=OFF -DCMAKE_Fortran_COMPILER=$(which mpif90) $FOPTS

            if [ "x$USEDASH" == "xTRUE" ]; then
                make Experimental ; CHECKERR

            else
                make && make test ; CHECKERR
            fi
            make clean
            cd ${HOME}
            echo ""
        fi

        if [ "x$USEAC" = "xTRUE" ]; then
            echo "[$FCOUNT | $FREPS] Testing netCDF-Fortran - AutoConf"
            echo "----------------------------------"
            sleep 2
            cd netcdf-fortran
            if [ ! -f "configure" ]; then
                autoreconf -if
            fi
            CC=`which mpicc` FC=`which mpif90` F90=`which mpif90` F77=`which mpif77` ./configure --enable-parallel-tests "$AC_FOPTS"
            make ; CHECKERR
            make check TESTS=""
            make check ; CHECKERR

            if [ "x$DISTCHECK" == "xTRUE" ]; then
                DISTCHECK_CONFIGURE_FLAGS="$AC_FOPTS" make distcheck ; CHECKERR
            fi

            make clean
            cd ${HOME}
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
            cmake ${HOME}/netcdf-cxx4 -DBUILDNAME_PREFIX="docker$BITNESS-parallel$PARTYPE" -DBUILDNAME_SUFFIX="$CXXBRANCH" -DCMAKE_CXX_COMPILER=$(which mpic++) $CXXOPTS

            if [ "x$USEDASH" == "xTRUE" ]; then
                make Experimental
            else
                make -j 4 && make test
            fi
            make clean
            cd ${HOME}
            echo ""
        fi

        if [ "x$USEAC" = "xTRUE" ]; then
            echo "[$CXXCOUNT | $CXXREPS] Testing netCDF-CXX4 - AutoConf"
            echo "----------------------------------"
            sleep 2
            cd netcdf-cxx4
            if [ ! -f "configure" ]; then
                autoreconf -if
            fi
            ./configure "$AC_CXXOPTS"
            make -j 4
            make check TESTS="" -j 4
            make check ; CHECKERR

            if [ "x$DISTCHECK" == "xTRUE" ]; then
                DISTCHECK_CONFIGURE_FLAGS="$AC_CXXOPTS" make distcheck ; CHECKERR
            fi

            make clean
            cd ${HOME}
            echo ""
        fi

        CXXCOUNT=$[CXXCOUNT+1]

    done
fi

###
# Build & test netcdf4-python.
# Doesn't work in parallel tests.
###
#
#if [ "x$RUNP" == "xTRUE" ]; then
#
#    while [[ $PCOUNT -le $PREPS ]]; do
#        echo "[$PCOUNT | $PREPS] Testing netcdf4-python"
#        cd ${HOME}/netcdf4-python
#        python setup.py build
#        python setup.py install
#        cd test
#        python run_all.py
#        cd ${HOME}
#
#        PCOUNT=$[PCOUNT+1]
#
#    done
#fi
