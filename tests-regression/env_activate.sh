#!/bin/bash
# Activate an arbitrary dev environment.
if [ "${BASEDIR}" = "" ]; then
    BASEDIR="${HOME}/environments"
fi
TARGDIR="${BASEDIR}/${1}"
ACTIVEENV="${1}"

DOHELP() {
    echo "Usage: . env_activate.sh [name of environment]"
    if [ "x$DEV_ENV" != "x" ]; then
        echo ""
        echo "Current active environment: ${DEV_ENV}"
    fi
    echo -e ""
    echo -e "Current BASEDIR: ${BASEDIR}"
    ls -alh "${BASEDIR}"
    echo -e ""
}

if [ $# -lt 1 ]; then
    DOHELP
else
    echo "Activating ${1}"
    if [ ! -d ${TARGDIR} ]; then
        echo -e "\tError: Can't find ${TARGDIR}"
        echo ""
    elif [ "x$DEV_ENV" != "x" ]; then
        echo -e "Environment ${DEV_ENV} already active. Use env_deactivate.sh to clear it."
    else
        echo ""
        set -x
        export DEV_ENV="${1}"
        export DEV_CPPFLAGS="${CPPFLAGS}"
        export DEV_CFLAGS="${CFLAGS}"
        export DEV_CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH}"
        export DEV_LDFLAGS="${LDFLAGS}"
        export DEV_LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"
        export DEV_LIBRARY_PATH="${LIBRARY_PATH}"
        export DEV_DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}"
        export DEV_PATH="${PATH}"
        export DEV_CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH}"
        export DEV_PKG_CONFIG_PATH="${PKG_CONFIG_PATH}"
        export CPPFLAGS="-I${TARGDIR}/include"
        export CFLAGS="-I${TARGDIR}/include"
        export CPLUS_INCLUDE_PATH="${CPLUS_INCLUDE_PATH}:${TARGDIR}/include"
        export LDFLAGS="-L${TARGDIR}/lib"
        export LD_LIBRARY_PATH="${TARGDIR}/lib:${LD_LIBRARY_PATH}"
        export LIBRARY_PATH="${LIBRARY_PATH}:${TARGDIR}/lib"
        export DYLD_LIBRARY_PATH="${TARGDIR}/lib"
        export PATH="${TARGDIR}/bin:$PATH"
        export CMAKE_PREFIX_PATH="${TARGDIR}:${CMAKE_PREFIX_PATH}"
        export PKG_CONFIG_PATH="${TARGDIR}/lib/pkgconfig:${PKG_CONFIG_PATH}"
        export HDF5_DISABLE_VERSION_CHECK=2
        if [ -d "/opt/homebrew" ]; then
            export CPPFLAGS="${CPPFLAGS} -I/opt/homebrew/include"
            export CFLAGS="${CPPFLAGS} -I/opt/homebrew/include"
            export LDFLAGS="${LDFLAGS} -L/opt/homebrew/lib"
            export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/homebrew/lib"
            export DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}:/opt/homebrew/lib"
        fi
        alias active="echo ${1}"
        alias active_full="echo ${TARGDIR}"
        alias active_env="echo ${TARGDIR}"
        alias active_dir="echo ${TARGDIR}"
        alias active_path="echo ${TARGDIR}/bin"
        alias active_lib="echo ${TARGDIR}/lib"
        alias active_include="echo ${TARGDIR}/include"
        alias old_path="echo ${DEV_PATH}"
        export active_dir="${TARGDIR}"
        export active_incdir="${TARGDIR}/include"
        export active_libdir="${TARGDIR}/lib"
        set +x
        echo ""
        echo "Activated environment ${1} in ${TARGDIR}"
    fi
fi
