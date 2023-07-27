#!/bin/bash

set -e
# set -x

#####
# Function to download HDF5 tarball and install it.
#####
installhdf5 () {

    cd "${TARGSUFFIX}"
    H5MAJ=$(echo $H5VER | cut -d '.' -f 1)
    H5MIN=$(echo $H5VER | cut -d '.' -f 2)
    H5REV=$(echo $H5VER | cut -d '.' -f 3)

    H5DIR="hdf5-${H5VER}"
    H5FILE="${H5DIR}.tar.bz2"
    H5URL="https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${H5MAJ}.${H5MIN}/hdf5-${H5VER}/src/${H5FILE}"

    if [ ! -f "../${H5FILE}" ]; then
        echo "Downloading ${H5FILE}"
        wget "${H5URL}"
        cp "${H5FILE}" ..
    else
        echo "${H5FILE} Found"
        cp "../${H5FILE}" .
    fi

    H5_API_OP="--with-default-api-version=v110"

    echo -e "\tUncompressing, Compiling HDF5"
    H5DIR="${H5DIR}-${TKEY}"
    mkdir -p "${H5DIR}"
    tar -jxf "${H5FILE}" --strip-components=2 -C "${H5DIR}"
    cd "${H5DIR}"
    autoreconf -if 

    PAROPT=""
    if [ "x${USE_CC}" = "xmpicc" ]; then
        PAROPT="--enable-parallel"
    fi

    CC="${USE_CC}" ./configure --disable-static --enable-shared --prefix="${TARGINSTALL}" "${H5PAROPT}" --enable-hl --with-szlib ${H5_API_OP} ${PAROPT}
    make install -j "${TESTPROC}" 
    make clean -j "${TESTPROC}"

    # Cleanup
    cd ..
    rm "${H5FILE}"
    cd ..
}

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
    # Were the AC-based artifacts generated These are the tar and zip files? If not, skip.

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

TKEY="$(date +%s)"
TARGROOT="$(pwd)"
TARGID="${TKEY}-${CBRANCH}-${H5VER}-${USE_CC}-artifacts"
TARGSUFFIX="$(pwd)/${TARGID}"
TARGINSTALL="${TARGSUFFIX}"

mkdir -p "${TARGSUFFIX}"
TARG_SRC_CDIR="${TARGSUFFIX}"/netcdf-c-src
TARG_BUILD_AC_CDIR="${TARGSUFFIX}"/netcdf-c-ac-build
TARG_BUILD_CMAKE_CDIR="${TARGSUFFIX}"/netcdf-c-cmake-build

LOGHTML="${TARGID}/index.html"

mkdir -p "${TARGINSTALL}/include"
mkdir -p "${TARGINSTALL}/lib"

export CFLAGS="-I${TARGINSTALL}/include"
export LDFLAGS="-L${TARGINSTALL}/lib"
export LD_LIBRARY_PATH="${TARGINSTALL}/lib:${LD_LIBRARY_PATH}"
export PATH="${TARGINSTALL}/bin:${PATH}"
export CC"=${USE_CC}"

##
# Create the diagnostic env file, just in case we need it.
# Also create html tree.
##
create_env_file
create_html_tree

##
# Install HDF5 from source.  
##
installhdf5

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

    cd "${TARG_BUILD_CMAKE_CDIR}" \
    && unbuffer cmake "${TARG_SRC_CDIR}" -DCMAKE_C_COMPILER="${USE_CC}" -DCMAKE_C_FLAGS="${CFLAGS}" 2>&1 | tee -a ${TARGSUFFIX}/cmake_configure_output.txt \
    && unbuffer make -j "${TESTPROC}" 2>&1 | tee -a ${TARGSUFFIX}/cmake_build_output.txt \
    && unbuffer ctest -j "${TESTPROC}" 2>&1 | tee -a  ${TARGSUFFIX}/cmake_ctest_output.txt 

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
   
    cd "${TARG_SRC_CDIR}" && autoreconf -if \
        && cd "${TARG_BUILD_AC_CDIR}" \
        && CC="${USE_CC}" unbuffer "${TARG_SRC_CDIR}"/configure --prefix="${TARGINSTALL}" 2>&1 | tee -a ${TARGSUFFIX}/ac_configure_output.txt \
        && unbuffer make check -j "${TESTPROC}" TESTS="" 2>&1 | tee -a ${TARGSUFFIX}/ac_build_output.txt \
        && unbuffer make check -j "${TESTPROC}" 2>&1 | tee -a ${TARGSUFFIX}/ac_make_check_output.txt \
        && unbuffer make install -j "${TESTPROC}" 2>&1 | tee -a ${TARGSUFFIX}/ac_make_install_output.txt 

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