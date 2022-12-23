#!/bin/bash

set -e
# set -x


#####
# Function to create an environment script that
# can be sourced, if need be.
#####
create_env_file () {
    ENVFILE="${TARGSUFFIX}"/env.sh
    echo "Creating ${ENVFILE}"
    echo -e "# Created $(date)" > "${ENVFILE}"
    echo "" >> "${ENVFILE}"
    echo -e "export CFLAGS=\"${CFLAGS}\"" >> "${ENVFILE}"
    echo -e "export LDFLAGS=\"${LDFLAGS}\"" >> "${ENVFILE}"
    echo -e "export LD_LIBRARY_PATH=\"${LD_LIBRARY_PATH}\"" >> "${ENVFILE}"
    echo -e "export CC=\"${USE_CC}\"" >> "${ENVFILE}"
    echo -e "export PATH=\"${PATH}\":\${PATH}" >> "${ENVFILE}"
    echo -e ""
    echo -e "export TARG_SRC_CDIR=\"${TARG_SRC_CDIR}\"" >> "${ENVFILE}"
    echo -e "export TARG_BUILD_AC_CDIR=\"${TARG_BUILD_AC_CDIR}\"" >> "${ENVFILE}"
    echo -e "export TARG_BUILD_CMAKE_CDIR=\"${TARG_BUILD_CMAKE_CDIR}\"" >> "${ENVFILE}"
    echo -e "" >> "${ENVFILE}"
    echo -e "$(env)" >> "${TARGSUFFIX}"/docker-env.txt
}   

#####
# End create_env_file()
#####

#####
# Create html tree
# o Append entry to top-level index.html file,
# o create links to the other files.
#####
create_html_tree () {
    INDFILE="${TARGROOT}/index.html"


    if [ ! -f "${INDFILE}" ]; then
        echo "<H1>Artifacts Directory</H1><P>" > "${INDFILE}"
        echo "<H2><A href=\".\">Local Directory Structure</A></H2><BR>" >> "${INDFILE}"
    fi
    echo "<A href=\"${LOGHTML}\">$(date) - ${TARGSUFFIX}</A><BR>" >> "${INDFILE}"
    
    echo "<H1>$(date)</H1></P>" > "${LOGHTML}"

    echo "<A href=\"../index.html\">Back</A><BR>" >> "${LOGHTML}" 
    echo "<A href=\".\">Local Directory Structure</A><BR>" >> "${LOGHTML}"
    echo "<ul>" >> "${LOGHTML}"
    # CMake-based build?
    if [ "${USECMAKE}" = "TRUE" ] || [ "${USECMAKE}" = "ON" ]; then
        echo "<li><A href=\"netcdf-c-cmake-build/libnetcdf.settings\">cmake-build/libnetcdf.settings</li>" >> "${LOGHTML}"
    else
        echo "<li>No Cmake Build</li>" >> "${LOGHTML}"
    fi

    # AC-based build?
    if [ "${USEAC}" = "TRUE" ] || [ "${USEAC}" = "ON" ]; then
        echo "<li><A href=\"netcdf-c-ac-build/libnetcdf.settings\">ac-build/libnetcdf.settings</li></A>" >> "${LOGHTML}"
    else
        echo "<li>No Autoconf Build</li>" >> "${LOGHTML}"
    fi
    echo "</ul>" >> "${LOGHTML}"
}

#####
# End create html tree.
#####

#####
# Function to copy artifacts from /workdir to  /artifacts
#####
publish_artifacts () {
    echo "Generating Artifacts"
    # Were the AC-based artifacts generated? If not, skip
    if [ "${USEAC}" = "TRUE" ] || [ "${USEAC}" = "ON" ]; then
        if [ "${DISTCHECK_C}" = "TRUE" ] || [ "${DISTCHECK_C}" = "ON" ]; then
            echo "Copying archive artifacts to ${TARGSUFFIX}"
            cp "${TARG_BUILD_AC_CDIR}"/*.tar.gz "${TARG_BUILD_AC_CDIR}"/*.zip "${TARGSUFFIX}"/
        elif [ "${DIST_C}" = "TRUE" ] || [ "${DIST_C}" = "ON" ]; then
            echo "Copying archive artifacts to ${TARGSUFFIX}"
            cp "${TARG_BUILD_AC_CDIR}"/*.tar.gz "${TARG_BUILD_AC_CDIR}"/*.zip "${TARGSUFFIX}"/
        fi
    fi

}
#####
# End publish_artifacts()
#####

if [ "$DOHELP" != "" ]; then
    cat "${HOME}"/README.md
    exit 0
fi


##
# Set some environmental variables
##


TKEY="$(date +%m%d%y%H%M%S)"
TARGROOT="$(pwd)"
TARGID="${TKEY}-${CBRANCH}-${USE_CC}-artifacts"
TARGSUFFIX="$(pwd)/${TARGID}"
TARGINSTALL="${TARGSUFFIX}"

mkdir -p "${TARGSUFFIX}"
TARG_SRC_CDIR="${TARGSUFFIX}"/netcdf-c-src
TARG_BUILD_AC_CDIR="${TARGSUFFIX}"/netcdf-c-ac-build
TARG_BUILD_CMAKE_CDIR="${TARGSUFFIX}"/netcdf-c-cmake-build

LOGHTML="${TARGID}/index.html"

export CFLAGS="-I${CONDA_PREFIX}/include -I${TARGINSTALL}/include"
export LDFLAGS="-L${CONDA_PREFIX}/lib -L${TARGINSTALL}/lib"
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib:${TARGINSTALL}/lib:${LD_LIBRARY_PATH}"
export PATH="${TARGINSTALL}/bin:${PATH}"
export CC=${USE_CC}

##
# Create the diagnostic env file, just in case we need it.
# Also create html tree.
##
create_env_file
create_html_tree

##
# Install some conda packages
##

conda install -c conda-forge hdf5 ncurses cmake bison make zip unzip autoconf automake libtool libxml2 -y

##
# Set some more environmental Variables
##


##
# NetCDF-C Process
#
# o Run cmake-based tests
# o Run autoconf-based tests
#   o (optional) run distcheck
#   
##

#
# Check out source code.
#
git clone https://www.github.com/Unidata/netcdf-c --single-branch --branch "${CBRANCH}" --depth 1 "${TARG_SRC_CDIR}"

#
# CMake-based tests
#

if [ "${USECMAKE}" != "FALSE" ]; then
    mkdir -p "${TARG_BUILD_CMAKE_CDIR}"

    cd "${TARG_BUILD_CMAKE_CDIR}" && cmake "${TARG_SRC_CDIR}" -DCMAKE_C_COMPILER="${USE_CC}" -DCMAKE_C_FLAGS="${CFLAGS}" && make -j "${TESTPROC}" && ctest -j "${TESTPROC}"
fi

#
# End CMake
# 

#
# Autoconf-based tests
#  - Out of directory build for autoconf-based tools, and also do distcheck.
#

if [ "${USEAC}" = "TRUE" ] || [ "${USEAC}" = "ON" ]; then

    mkdir -p "${TARG_BUILD_AC_CDIR}"
   
    cd "${TARG_SRC_CDIR}" && autoreconf -if && cd "${TARG_BUILD_AC_CDIR}" && CC="${USE_CC}" "${TARG_SRC_CDIR}"/configure --prefix="${TARGINSTALL}" && make check -j "${TESTPROC}" TESTS="" && make check -j "${TESTPROC}" && make install -j "${TESTPROC}"

    if [ "${DISTCHECK_C}" = "TRUE" ] || [ "${DISTCHECK_C}" = "ON" ]; then
        cd "${TARG_BUILD_AC_CDIR}" && make distcheck -j "${TESTPROC}"
    elif [ "${DIST_C}" = "TRUE" ] || [ "${DIST_C}" = "ON" ]; then
        cd "${TARG_BUILD_AC_CDIR}" && make dist -j "${TESTPROC}"
    fi


fi
#
# End Autoconf
#

##
# Publish artifacts. Checks for which artifacts to publish are made
# in the function itself
##
publish_artifacts

echo "!!!!! TODO: CREATE SUMMARY OUTPUT FILE !!!!!"