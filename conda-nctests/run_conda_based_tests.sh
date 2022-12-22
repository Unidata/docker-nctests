#!/bin/bash

set -e
# set -x

if [ "x$DOHELP" != "x" ]; then
    cat "${HOME}"/README.md
    exit 0
fi

##
# Function to copy artifacts from /workdir to  /artifacts
##
publish_artifacts () {
    ARTTARG=${ARTDIR}/${TKEY}-artifacts
    mkdir -p "${ARTTARG}"
    # Were the artifacts generated? If not, skip
    if [ "x${DISTCHECK_C}" != "x" ]; then
        echo "Copying archive artifacts to ${ARTTARG}"
        cp "${TARG_BUILD_AC_CDIR}"/*.tar.gz "${TARG_BUILD_AC_CDIR}"/*.zip "${ARTTARG}"/
    fi

}

##
# Set some environmental variables
##


TKEY="$(date +%m%d%y%H%M%S)"
TARGSUFFIX="$(pwd)/${TKEY}-artifacts"
TARGINSTALL="${TARGSUFFIX}"

mkdir -p "${TARGSUFFIX}"
TARG_SRC_CDIR="${TARGSUFFIX}"/netcdf-c-src
TARG_BUILD_AC_CDIR="${TARGSUFFIX}"/netcdf-c-ac-build
TARG_BUILD_CMAKE_CDIR="${TARGSUFFIX}"/netcdf-c-cmake-build

export CFLAGS="-I${CONDA_PREFIX}/include -I${TARGINSTALL}/include"
export LDFLAGS="-L${CONDA_PREFIX}/lib -L${TARGINSTALL}/lib"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${CONDA_PREFIX}/lib:${TARGINSTALL}/lib"
export PATH="${TARGINSTALL}/bin:${PATH}"
export CC=${USE_CC}

##
# Install some conda packages
##

conda install -c conda-forge hdf5 ncurses cmake bison make zip unzip autoconf automake libtool -y

##
# Set some more environmental Variables
##


##
# NetCDF-C Process
##

#
# Check out source code.
#
git clone https://www.github.com/Unidata/netcdf-c --single-branch --branch "${CBRANCH}" --depth 1 "${TARG_SRC_CDIR}"

#
# Autoconf-based tests
#  - Out of directory build for autoconf-based tools, and also do distcheck.
#

if [ "x${USEAC}" = "xTRUE" ] || [ "x${USEAC}" = "xON" ]; then

    mkdir -p "${TARG_BUILD_AC_CDIR}"
   
    cd "${TARG_SRC_CDIR}" && autoreconf -if && cd "${TARG_BUILD_AC_CDIR}" && CC="${USE_CC}" "${TARG_SRC_CDIR}"/configure --prefix="${TARGINSTALL}" && make check -j "${TESTPROC}" TESTS="" && make check -j "${TESTPROC}" && make install -j "${TESTPROC}"

    if [ "x${DISTCHECK_C}" != "x" ]; then
        cd "${TARG_BUILD_AC_CDIR}" && make distcheck -j "${TESTPROC}"
        publish_artifacts
    fi
fi
#
# End Autoconf
#

#
# CMake-based tests
#

if [ "x${USECMAKE}" != "xFALSE" ]; then
    mkdir -p "${TARG_BUILD_CMAKE_CDIR}"

    cd "${TARG_BUILD_CMAKE_CDIR}" && cmake "${TARG_SRC_CDIR}" -DCMAKE_C_COMPILER="${USE_CC}" -DCMAKE_C_FLAGS="${CFLAGS}" && make -j "${TESTPROC}" && ctest -j "${TESTPROC}"
fi

#
# End CMake
# 

echo "!!!!! TODO: CREATE SUMMARY OUTPUT FILE !!!!!"