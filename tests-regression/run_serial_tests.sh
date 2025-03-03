#!/bin/bash

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

echo -e "Running Serial Tests"

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
cat /home/tester/VERSION.md
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

if [ -d "${C_VOLUME_MAP}" ]; then
    echo "Using local netcdf-c repository"
    if [ "x$USE_LOCAL_CP" == "xTRUE" ]; then
        cp -R ${C_VOLUME_MAP} ${HOME}
    else
        git clone ${C_VOLUME_MAP} ${HOME}${C_VOLUME_MAP}
    fi
else
    echo "Using remote netcdf-c repository"
    git clone http://www.github.com/Unidata/netcdf-c --single-branch --branch $CBRANCH --depth=1 $CBRANCH
    mv $CBRANCH netcdf-c
fi

if [ "x$RUNF" == "xTRUE" ]; then

    if [ -d "${FORTRAN_VOLUME_MAP}" ]; then
        echo "Using local netcdf-fortran repository"
        if [ "x$USE_LOCAL_CP" != "xTRUE" ]; then
            cp -R ${FORTRAN_VOLUME_MAP} ${HOME}
        else
            git clone ${FORTRAN_VOLUME_MAP} ${HOME}${FORTRAN_VOLUME_MAP}
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

    if [ -d "${CXX4_VOLUME_MAP}" ]; then
        echo "Using local netcdf-cxx4 repository"
        if [ "x$USE_LOCAL_CP" == "xTRUE" ]; then
            cp -R ${CXX4_VOLUME_MAP} ${HOME}
        else
            git clone ${CXX4_VOLUME_MAP} ${HOME}${CXX4_VOLUME_MAP}
        fi

        else
        echo "Using remote netcdf-cxx4 repository"
        git clone http://www.github.com/Unidata/netcdf-cxx4 --single-branch --branch $CXXBRANCH --depth=1 $CXXBRANCH
        mv $CXXBRANCH netcdf-cxx4
    fi
else
    echo "Skipping CXX"
fi


if [ "x$RUNJAVA" == "xTRUE" ]; then

    if [ -d "${JAVA_VOLUME_MAP}" ]; then
        echo "Using local netcdf-cxx4 repository"
        if [ "x$USE_LOCAL_JAVA" == "xTRUE" ]; then
            cp -R ${JAVA_VOLUME_MAP} ${HOME}
        else
            git clone ${JAVA_VOLUME_MAP} ${HOME}${JAVA_VOLUME_MAP}
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
        #git clone /netcdf4-python ${HOME}/netcdf4-python
        cp -R /netcdf4-python ${HOME}
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
        #git clone /nco ${HOME}/nco
        cp -R /nco ${HOME}
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

##
# Allow us to build dependencies from source.
# For now, just HDF5
##
#if [ "x${HDF5SRC}" != "x" ]; then
if [ ! -d "${TARGDIR}" ]; then
    echo "Building HDF5 ${H5VER} from source."
    sudo ./install_hdf5.sh -c "${USE_CC}" -d "${H5VER}" -j "${TESTPROC}" -t "${TARGDIR}"
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
        cmake ${HOME}${C_VOLUME_MAP} -DCMAKE_INSTALL_PREFIX=${TARGDIR} -DNETCDF_ENABLE_HDF4=OFF -DNETCDF_ENABLE_MMAP=ON -DBUILDNAME_PREFIX="docker$BITNESS-$USE_CC" -DBUILDNAME_SUFFIX="$CBRANCH" -DCMAKE_C_COMPILER=$USE_CC $COPTS -DCMAKE_C_FLAGS="${CMEM}" -D NETCDF_ENABLE_TESTS="${RUNC}"; CHECKERR
        make clean

        if [ "x$RUNC" == "xTRUE" ]; then

            if [ "x$USEDASH" == "xTRUE" ]; then
                ctest -D Experimental -j $TESTPROC ; CHECKERR
                if [ "x$USE_VALGRIND" == "xTRUE" ]; then
                    make ExperimentalMemCheck
                    make ExperimentalSubmit
                fi
            else
                make -j $TESTPROC && ctest -j $TESTPROC ; CHECKERR
                if [ "x$USE_VALGRIND" == "xTRUE" ]; then
                    make ExperimentalMemCheck
                fi
            fi

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
        CC=$USE_CC ./configure --prefix=${TARGDIR} --disable-hdf4 --enable-extra-tests --enable-mmap $AC_COPTS
        make clean
        make -j $TESTPROC ; CHECKERR
        if [ "x$RUNC" == "xTRUE" ]; then
            make check TESTS="" -j $TESTPROC ; CHECKERR
            make check -j $TESTPROC ; CHECKERR

            if [ "x$DISTCHECK" == "xTRUE" ]; then
                DISTCHECK_CONFIGURE_FLAGS="--disable-hdf4 --enable-extra-tests --enable-mmap $AC_COPTS" make distcheck ; CHECKERR
            fi

        fi
        cd ${HOME}
        echo ""
    fi

    CCOUNT=$[$CCOUNT+1]
done


if [ "x$USECMAKE" = "xTRUE" ]; then
    cd build-netcdf-c
    make -j "${TESTPROC}"
    sudo make install
elif [ "x$USEAC" = "xTRUE" ]; then
    cd netcdf-c
    sudo make install -j $TESTPROC
fi

cd ${HOME}

sudo ldconfig

###
# Build & test netcdf-fortran
###
if [ "x$RUNF" == "xTRUE" ]; then

  if [ "x$FORTRAN_SERIAL_BUILD" != "x" ]; then
      TESTPROC_FORTRAN="1"
  fi

    while [[ $FCOUNT -le $FREPS ]]; do

        if [ "x$USECMAKE" = "xTRUE" ]; then
            echo "[$FCOUNT | $FREPS] Testing netCDF-Fortran - CMAKE"
            echo "----------------------------------"
            cd ${HOME}
            mkdir -p build-netcdf-fortran
            cd build-netcdf-fortran
            cmake ${HOME}${FORTRAN_VOLUME_MAP} -DBUILDNAME_PREFIX="docker$BITNESS-$USE_CC" -DBUILDNAME_SUFFIX="$FBRANCH" -DCMAKE_C_COMPILER=$USE_CC $FOPTS
            if [ "x$USEDASH" == "xTRUE" ]; then
                ctest -j $TESTPROC_FORTRAN -D Experimental
            else
                make -j $TESTPROC_FORTRAN ; CHECKERR
                ctest -j $TESTPROC_FORTRAN ; CHECKERR
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
            CC=$USE_CC ./configure "$AC_FOPTS"
            make -j $TESTPROC_FORTRAN ; CHECKERR
            make check TESTS="" -j $TESTPROC_FORTRAN
            make check -j $TESTPROC_FORTRAN ; CHECKERR

            if [ "x$DISTCHECK" == "xTRUE" ]; then
                DISTCHECK_CONFIGURE_FLAGS="$AC_FOPTS" make distcheck -j $TESTPROC_FORTRAN ; CHECKERR
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
            cmake ${HOME}${CXX4_VOLUME_MAP} -DBUILDNAME_PREFIX="docker$BITNESS-$USE_CXX" -DBUILDNAME_SUFFIX="$CXXBRANCH" -DCMAKE_CXX_COMPILER=$USE_CXX $CXXOPTS
            if [ "x$USEDASH" == "xTRUE" ]; then
                ctest -D Experimental ; CHECKERR
            else
                make -j $TESTPROC && ctest ; CHECKERR
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
            CXX=$USE_CXX ./configure "$AC_CXXOPTS"
            make -j ${TESTPROC}; CHECKERR
            make check TESTS="" -j ${TESTPROC_CXX}; CHECKERR
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
# Build & test netcdf-java
###
if [ "x$RUNJAVA" == "xTRUE" ]; then
    echo -e "o Testing netcdf-java"
    sudo apt update && sudo apt install -y openjdk-${JDKVER}-jdk
    cd ${HOME}${JAVA_VOLUME_MAP}
    JNA_PATH=${LIBDIR} ./gradlew clean :netcdf4:test
    ./gradlew clean classes
    cd ${HOME}

fi

###
# Build & test netcdf4-python.
###

if [ "x$RUNP" == "xTRUE" ]; then

    while [[ $PCOUNT -le $PREPS ]]; do
        echo "[$PCOUNT | $PREPS] Testing netcdf4-python"
        cd ${HOME}/netcdf4-python
        python setup.py build
        sudo python setup.py install
        cd test
        python run_all.py
        cd ${HOME}

        PCOUNT=$[PCOUNT+1]

    done

fi


###
# Build & test NCO
###
if [ "x$RUNNCO" == "xTRUE" ]; then

    while [[ $NCOCOUNT -le $NCOREPS ]]; do
        echo "[$NCOCOUNT | $NCOREPS] Testing NCO"
        cd ${HOME}/nco
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
