#!/bin/bash

set -e
set -x

##
# Set some environmental variables
##
export CFLAGS="-I${CONDA_PREFIX}/include"
export LDFLAGS="-L${CONDA_PREFIX}/lib"
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib"
export CC=${USE_CC}

conda install -c conda-forge ncurses hdf5 autoconf cmake bison automake libtool make zip unzip -y

TARGSUFFIX="$(pwd)/$(date +%m%d%y%H%M%S)"
mkdir -p ${TARGSUFFIX}
TARG_SRC_CDIR="${TARGSUFFIX}/netcdf-c-src"
TARG_BUILD_CDIR="${TARGSUFFIX}/netcdf-c-build"

mkdir -p ${TARG_BUILD_CDIR}

git clone https://www.github.com/Unidata/netcdf-c --single-branch --branch ${CBRANCH} --depth 1 ${TARG_SRC_CDIR}
cd ${TARG_SRC_CDIR} && autoreconf -if && cd ${TARG_BUILD_CDIR} && ${TARG_SRC_CDIR}/configure  && make check -j 12 TESTS="" && make check -j 12
cd ${TARG_BUILD_CDIR} && make distcheck -j 12