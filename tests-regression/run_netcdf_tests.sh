#!/bin/bash
#
# Run the netCDF regression test suite.  Combination of two, older files,
# `run_serial_tests.sh` and `run_par_tests.sh`
# 

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

if [ "${USER}" = "root" ]; then
    export SUDOCMD=""
else
    export SUDOCMD="sudo"
fi

cd ${WORKING_DIRECTORY}

if [ "x$HELP" != "x" ]; then
    cat /home/tester/README.md
    echo ""
    cat /home/tester/VERSION.md
    echo ""
    echo "HDF5 Versions Available (H5VER):"
    ls /environments/
    echo ""
    exit
fi

if [ "x$CMD" = "xhelp" ]; then
    cat /home/tester/README.md
    echo ""
    cat /home/tester/VERSION.md
    echo ""
    echo "HDF5 Versions Available (H5VER):"
    ls /environments/
    echo ""
    exit
fi

if [ "x$VERSION" != "x" ]; then
    cat /home/tester/VERSION.md
    echo ""
    exit
fi


CHECKERRJAVA() {

    RES=$?

    if [ -d "/results" ]; then
        # prepare netCDF-Java results directory
        if [ -d "/results/netcdf-java" ]; then
            rm -rf /results/netcdf-java/*
        else
            mkdir /results/netcdf-java
        fi
        # copy junit test report
        if [ -f "./netcdf4/build/reports/tests/test/index.html" ]; then
            cp -r netcdf4/build/reports/tests/test/* /results/netcdf-java
        fi
        # copy java error log file if something in the netCDF-C stack trigggers
        # a core dump
        find ./netcdf4 -maxdepth 1 -name \*.log -exec cp {} /results/netcdf-java \;
    fi

    if [[ $RES -ne 0 ]]; then
        echo "Error Caught: $RES"
        exit $RES
    fi

}

CHECKERR() {

    RES=$?

    if [[ $RES -ne 0 ]]; then
        echo "Error Caught: $RES"
        exit $RES
    fi

}

CHECKERR_AC() {

    RES=$?

    if [[ $RES -ne 0 ]]; then
        echo "Error Caught: $RES"
        find . -name 'test-suite.log' -exec cat {} \;
        exit $RES
    fi

}

###
# Print out version.
###
cat /home/tester/VERSION.md
if [ "${USE_CC}" = "mpicc" -a "${MPICHVER}" != "" ]; then
    echo "Using MPICH version: ${MPICHVER}"
fi

echo "Using HDF5 version: ${H5VER}"
echo ""
sleep 3
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
        cp -R /netcdf-c ${WORKING_DIRECTORY}
        export CBRANCH='local-copy-$(date +%s)'
    else
        git config --global --add safe.directory /netcdf-c/.git
        git clone /netcdf-c ${WORKING_DIRECTORY}/netcdf-c
        cd netcdf-c
        export CBRANCH=$(echo $(git log | head -n 1 | cut -d " " -f 2| head -c 6 ))
        cd ..
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
            cp -R /netcdf-fortran ${WORKING_DIRECTORY}
            export FBRANCH='local-copy-$(date +%s)'
        else
            git config --global --add safe.directory /netcdf-fortran/.git
            git clone /netcdf-fortran ${WORKING_DIRECTORY}/netcdf-fortran
            cd netcdf-fortran
            export FBRANCH=$(echo $(git log | head -n 1 | cut -d " " -f 2| head -c 6 ))
            cd ..
        fi
    else
        echo "Using remote netcdf-fortran repository"
        git clone http://www.github.com/Unidata/netcdf-fortran --single-branch --branch $FBRANCH --depth=1 $FBRANCH
        mv $FBRANCH netcdf-fortran
    fi
else
    echo "Skipping Fortran"
fi


if [ "x$RUNCXX4" == "xTRUE" ]; then

    if [ -d "/netcdf-cxx4" ]; then
        echo "Using local netcdf-cxx4 repository"
        if [ "x$USE_LOCAL_CP" == "xTRUE" ]; then
            cp -R /netcdf-cxx4 ${WORKING_DIRECTORY}
            export CXX4BRANCH='local-copy-$(date +%s)'
        else
            git config --global --add safe.directory /netcdf-cxx4/.git
            git clone /netcdf-cxx4 ${WORKING_DIRECTORY}/netcdf-cxx4
            cd netcdf-cxx4
            export CXX4BRANCH=$(echo $(git log | head -n 1 | cut -d " " -f 2| head -c 6 ))
            cd ..
        fi

        else
        echo "Using remote netcdf-cxx4 repository"
        git clone http://www.github.com/Unidata/netcdf-cxx4 --single-branch --branch $CXX4BRANCH --depth=1 $CXX4BRANCH
        mv $CXX4BRANCH netcdf-cxx4
    fi
else
    echo "Skipping CXX4"
fi


if [ "x$RUNJAVA" == "xTRUE" ]; then

    if [ -d "/netcdf-java" ]; then
        echo "Using local netcdf-java repository"
        if [ "x$USE_LOCAL_JAVA" == "xTRUE" ]; then
            cp -R /netcdf-java ${WORKING_DIRECTORY}
            export JAVABRANCH='local-copy-$(date +%s)'
        else
            git config --global --add safe.directory /netcdf-java/.git
            git clone /netcdf-java ${WORKING_DIRECTORY}/netcdf-java
            cd netcdf-java
            export JAVABRANCH=$(echo $(git log | head -n 1 | cut -d " " -f 2| head -c 6 ))
            cd ..
        fi

        else
        echo "Using remote netcdf-java repository"
        git clone http://www.github.com/Unidata/netcdf-java --single-branch --branch $JAVABRANCH --depth=1 $JAVABRANCH
        mv $JAVABRANCH netcdf-java
    fi
else
    echo "Skipping Java"
fi

if [ "x$RUNP" == "xTRUE" ]; then
    if [ -d "/netcdf4-python" ]; then
        echo "Using local netcdf4-python repository"
        #git clone /netcdf4-python ${WORKING_DIRECTORY}/netcdf4-python
        cp -R /netcdf4-python ${WORKING_DIRECTORY}
    else
        echo "Using remote netcdf4-python repository"
        git clone http://github.com/Unidata/netcdf4-python --single-branch --branch $PBRANCH --depth=1 $PBRANCH
        mv $PBRANCH netcdf4-python
    fi
else
    echo "Skipping Python"
fi

if [ "x$RUNNCO" == "xTRUE" ]; then
    if [ -d "/nco" ]; then
        echo "Using local NCO repository"
        #git clone /nco ${WORKING_DIRECTORY}/nco
        cp -R /nco ${WORKING_DIRECTORY}
    else
        echo "Using remote NCO repository"
        git clone https://github.com/nco/nco.git --single-branch --branch $NCOBRANCH --depth=1 $NCOBRANCH
        mv $NCOBRANCH nco
    fi
else
    echo "Skipping NCO"
fi

#

## 
# Set Target Dir
##
export TARGDIR="/environments/${H5VER}-${CBRANCH}-${USE_CC}"
echo "Using TARGDIR=${TARGDIR}"

###
# Install specific version of MPICH
###
if [ "${USE_CC}" = "mpicc" -a "${MPICHVER}" != "" ]; then
    ${SUDOCMD} /home/tester/install_mpich.sh -v ${MPICHVER}
fi

##
# Allow us to build dependencies from source.
# For now, just HDF5
##
#if [ "x${HDF5SRC}" != "x" ]; then
if [ ! -d "${TARGDIR}" ]; then
    echo "Building HDF5 ${H5VER} from source."
    ${SUDOCMD} /home/tester/install_hdf5.sh -c "${USE_CC}" -d "${H5VER}" -j "${TESTPROC}" -t "${TARGDIR}"
fi

###
# Configure Environmental Variables
###

export CPPFLAGS="-I${TARGDIR}/include"
export CFLAGS="-I${TARGDIR}/include"
export LDFLAGS="-L${TARGDIR}/lib"
export LD_LIBRARY_PATH="${TARGDIR}/lib"
export LIBDIR="${TARGDIR}/lib"
export PATH="${TARGDIR}/bin:$PATH"
export CMAKE_PREFIX_PATH="${TARGDIR}"
export USE_FC="gfortran"
###
# If we are using a parallel compiler (mpicc), 
# set some additional variables. 
###
if [ "${USE_CC}" = "mpicc" ]; then
    echo "Setting up parallel environment."
    export OMPI_MPICC=$USE_CC
    export OMPI_CC=$USE_CC
    export OMPI_CXX=$USE_CXX
    export CMAKE_PAR_OPTS="-DENABLE_PARALLEL_TESTS=${RUNC} -DENABLE_PNETCDF=${RUNC}"
    export CMAKE_PAR_OPTS_FORTRAN="-DCMAKE_Fortran_COMPILER=$(which mpifort)"
    export USE_FC=mpifort

    if [ "${RUNC}" = "TRUE" ]; then
        export AC_PAR_OPTS="--enable-parallel-tests --enable-pnetcdf"
    else
        export AC_PAR_OPTS="--disable-parallel-tests --disable-pnetcdf"
    fi

    if [ "${RUNF}" = "TRUE" ]; then
        export USE_FC=mpifort
        if [ ${TESTPROC_FORTRAN} -lt 4 ]; then
            echo ""
            echo "Updating TESTPROC_FORTRAN from ${TESTPROC_FORTRAN} to 4!!!"
            export TESTPROC_FORTRAN=4
            echo ""
        fi
    fi
    export RUNP=OFF
    export RUNJAVA=OFF
    export RUNNCO=OFF

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

cd ${WORKING_DIRECTORY}


# CREPS is defined as an environmental variable.

###
# Determine if we are doing memory checks.
###
CMEM=""
if [ "x$ENABLE_C_MEMCHECK" == "xTRUE" ]; then
    CMEM="-fsanitize=address -fno-omit-frame-pointer"
fi


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
        cmake ${WORKING_DIRECTORY}/netcdf-c -DCMAKE_INSTALL_PREFIX=${TARGDIR} -DNETCDF_ENABLE_HDF4=OFF -DNETCDF_ENABLE_MMAP=ON -DBUILDNAME_PREFIX="docker$BITNESS-$USE_CC" -DBUILDNAME_SUFFIX="$CBRANCH" -DCMAKE_C_COMPILER=$USE_CC ${CMAKE_PAR_OPTS} $COPTS -DCMAKE_C_FLAGS="${CMEM}" -DENABLE_TESTS="${RUNC}"; CHECKERR
        make clean

        if [ "x$RUNC" == "xTRUE" ]; then

            if [ "x$USEDASH" == "xTRUE" ]; then
                ctest -D Experimental -j $TESTPROC ; CHECKERR
                if [ "x$USE_VALGRIND" == "xTRUE" ]; then
                    make ExperimentalMemCheck
                    make ExperimentalSubmit
                fi
            else
                make -j $TESTPROC && ctest --repeat until-pass:${CTEST_REPEAT} -j$TESTPROC; CHECKERR
                if [ "x$USE_VALGRIND" == "xTRUE" ]; then
                    make ExperimentalMemCheck
                fi
            fi

        fi
        cd ${WORKING_DIRECTORY}
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
        CC=$USE_CC ./configure --prefix=${TARGDIR} ${AC_PAR_OPTS} --disable-hdf4 --enable-extra-tests --enable-mmap $AC_COPTS
        make clean
        make -j $TESTPROC ; CHECKERR
        if [ "x$RUNC" == "xTRUE" ]; then
            make check TESTS="" -j $TESTPROC ; CHECKERR
            make check -j $TESTPROC ; CHECKERR_AC

            if [ "x$DISTCHECK" == "xTRUE" ]; then
                DISTCHECK_CONFIGURE_FLAGS="--disable-hdf4 --enable-extra-tests --enable-mmap $AC_COPTS" make distcheck ; CHECKERR
            fi

        fi
        cd ${WORKING_DIRECTORY}
        echo ""
    fi

    CCOUNT=$[$CCOUNT+1]
done

if [ "${RUNF}" = "TRUE" -o "${RUNJAVA}" = "TRUE" -o "${RUNNCO}" = "TRUE" -o "${RUNP}" = "TRUE" -o "${RUNCXX4}" = "TRUE" ]; then
    echo ""
    echo -e "o RUNF: ${RUNF}"
    echo -e "o RUNJAVA: ${RUNJAVA}"
    echo -e "o RUNNCO: ${RUNNCO}"
    echo -e "o RUNP: ${RUNP}"
    echo -e "o RUNCXX4: ${RUNCXX4}"
    echo ""


    if [ "x$USECMAKE" = "xTRUE" ]; then
        cd build-netcdf-c
        make -j "${TESTPROC}"
        ${SUDOCMD} make install
    elif [ "x$USEAC" = "xTRUE" ]; then
        cd netcdf-c
        ${SUDOCMD} make install -j $TESTPROC
    fi

    cd ${WORKING_DIRECTORY}

    ${SUDOCMD} ldconfig
fi
###
# Build & test netcdf-fortran
###
if [ "x$RUNF" == "xTRUE" ]; then

    while [[ $FCOUNT -le $FREPS ]]; do

        if [ "x$USECMAKE" = "xTRUE" ]; then
            echo "[$FCOUNT | $FREPS] Testing netCDF-Fortran - CMAKE"
            echo "----------------------------------"
            cd ${WORKING_DIRECTORY}
            mkdir -p build-netcdf-fortran
            cd build-netcdf-fortran
            cmake ${WORKING_DIRECTORY}/netcdf-fortran -DBUILDNAME_PREFIX="docker$BITNESS-$USE_CC" -DBUILDNAME_SUFFIX="$FBRANCH" -DCMAKE_C_COMPILER=$USE_CC ${CMAKE_PAR_OPTS_FORTRAN} $FOPTS
            if [ "x$USEDASH" == "xTRUE" ]; then
                ctest --repeat until-pass:${CTEST_REPEAT} -j$TESTPROC_FORTRAN -D Experimental
            else
                make -j $TESTPROC_FORTRAN ; CHECKERR
                ctest --repeat until-pass:${CTEST_REPEAT} -j$TESTPROC_FORTRAN ; CHECKERR
            fi
            make clean
            cd ${WORKING_DIRECTORY}
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
            CC=$USE_CC FC=${USE_FC} F77=${USE_FC} ./configure "$AC_FOPTS"
            make -j $TESTPROC_FORTRAN ; CHECKERR
            make check TESTS="" -j $TESTPROC_FORTRAN
            make check -j $TESTPROC_FORTRAN ; CHECKERR_AC

            if [ "x$DISTCHECK" == "xTRUE" ]; then
                DISTCHECK_CONFIGURE_FLAGS="$AC_FOPTS" make distcheck -j $TESTPROC_FORTRAN ; CHECKERR
            fi

            make clean
            cd ${WORKING_DIRECTORY}
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
            cmake ${WORKING_DIRECTORY}/netcdf-c -DBUILDNAME_PREFIX="docker$BITNESS-$USE_CXX" -DBUILDNAME_SUFFIX="$CXXBRANCH" -DCMAKE_CXX_COMPILER=$USE_CXX $CXXOPTS
            if [ "x$USEDASH" == "xTRUE" ]; then
                ctest -D Experimental ; CHECKERR
            else
                make -j $TESTPROC && ctest ; CHECKERR
            fi
            make clean
            cd ${WORKING_DIRECTORY}
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
            CXX=$USE_CXX ./configure "$AC_CXXOPTS"
            make -j ${TESTPROC}; CHECKERR
            make check TESTS="" -j ${TESTPROC_CXX}; CHECKERR
            make check ; CHECKERR

            if [ "x$DISTCHECK" == "xTRUE" ]; then
                DISTCHECK_CONFIGURE_FLAGS="$AC_CXXOPTS" make distcheck ; CHECKERR
            fi

            make clean
            cd ${WORKING_DIRECTORY}
            echo ""
        fi

        CXXCOUNT=$[CXXCOUNT+1]

    done

fi

###
# Build & test netcdf-java
###
if [ "x$RUNJAVA" == "xTRUE" ]; then
    echo -e "o Testing netcdf-java"

    ${SUDOCMD} apt update && sudo apt install -y openjdk-${JDKVER}-jdk
    cd ${WORKING_DIRECTORY}/netcdf-java

    GRADLE_OPTS="-DrunSlowTests=True"
    if [ -d "/share/testdata/cdmUnitTest" ]; then
        GRADLE_OPTS="${GRADLE_OPTS} -Dunidata.testdata.path=/share/testdata"
    fi

    # run netCDF-Java tests that rely on the netCDF-C library
    # and do not trigger trap on failure
    JNA_PATH=${LIBDIR} ./gradlew ${GRADLE_OPTS} clean :netcdf4:test ; CHECKERRJAVA


    cd ${WORKING_DIRECTORY}

fi

###
# Build & test netcdf4-python.
###

if [ "x$RUNP" == "xTRUE" ]; then

    while [[ $PCOUNT -le $PREPS ]]; do
        echo "[$PCOUNT | $PREPS] Testing netcdf4-python"
        cd ${WORKING_DIRECTORY}/netcdf4-python
        python setup.py build
        ${SUDOCMD} python setup.py install
        cd test
        python run_all.py
        cd ${WORKING_DIRECTORY}

        PCOUNT=$[PCOUNT+1]

    done

fi


###
# Build & test NCO
###
if [ "x$RUNNCO" == "xTRUE" ]; then

    while [[ $NCOCOUNT -le $NCOREPS ]]; do
        echo "[$NCOCOUNT | $NCOREPS] Testing NCO"
        cd ${WORKING_DIRECTORY}/nco
        CC=$USE_CC ./configure
        make
        make check
        NCOCOUNT=$[NCOCOUNT+1]

        if [ "x$NCOMAKETEST" != "x" ]; then
            export DATA=$HOME/tmp
            mkdir -p $DATA
            echo "Running 'make test'. This may take several moments."
            set -e
            make test &> tst.log
            X=`grep -i unidata tst.log | wc -l`
            set +e
            if [[ $X -gt 0 ]]; then
                cat tst.log
                echo "Error Caught in NCO: make test"
                exit -1
            fi
        fi

    done

fi
