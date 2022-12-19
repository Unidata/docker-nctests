#!/bin/bash

set -x

if [ "x$DOHELP" != "x" ]; then
    cat "${HOME}"/README.md
    exit 0
fi

##
# Function to copy artifacts from /workdir to  /artifacts
##
publish_artifacts () {
    ARTTARG=${ARTDIR}/${TKEY}-artifacts
    mkdir -p ${ARTTARG}
    # Were the artifacts generated? If not, skip
    if [ "x${DISTCHECK_C}" != "x" ]; then
        echo "Copying archive artifacts to ${ARTTARG}"
        cp "${TARG_BUILD_CDIR}"/*.tar.gz "${TARG_BUILD_CDIR}"/*.zip "${ARTTARG}"/
    fi

}

##
# Set some environmental variables
##
export CFLAGS="-I${CONDA_PREFIX}/include"
export LDFLAGS="-L${CONDA_PREFIX}/lib"
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib"
export CC=${USE_CC}
TKEY="$(date +%m%d%y%H%M%S)"
TARGSUFFIX="$(pwd)/${TKEY}-working"
mkdir -p "${TARGSUFFIX}"
TARG_SRC_CDIR="${TARGSUFFIX}"/netcdf-c-src
TARG_BUILD_CDIR="${TARGSUFFIX}"/netcdf-c-build

##
# Install some conda packages
##
conda install -c conda-forge ncurses hdf5 autoconf cmake bison automake libtool make zip unzip -y

##
# Set some more environmental Variables
##


##
# NetCDF-C Process
##

#
# Autoconf-based tests
#  - Out of directory build for autoconf-based tools, and also do distcheck.
#

mkdir -p "${TARG_BUILD_CDIR}"
git clone https://www.github.com/Unidata/netcdf-c --single-branch --branch "${CBRANCH}" --depth 1 "${TARG_SRC_CDIR}"
cd "${TARG_SRC_CDIR}" && autoreconf -if && cd "${TARG_BUILD_CDIR}" && "${TARG_SRC_CDIR}"/configure  && make check -j "${TESTPROC}" TESTS="" && make check -j "${TESTPROC}"

if [ "x${DISTCHECK_C}" != "x" ]; then
    cd "${TARG_BUILD_CDIR}" && make distcheck -j "${TESTPROC}"
    publish_artifacts
fi

#
# End Autoconf
#

echo "!!!!! TODO: CREATE SUMMARY OUTPUT FILE !!!!!"