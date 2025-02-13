#!/bin/bash
#
# Utility bottle script to take  argument and install hdf5.
#

H5VER=""
H4VER=""
H5COMPRESSION="bz2"
H5UNTAR="tar -jxf"
PNETCDFVER="1.12.3"
NCCOMP="gcc"
NUMPROC=$(nproc)
DOPAR=""
USEBUILD="ac"
BUILDTYPE="shared"
BUILDARGAC="--disable-static --enable-shared"
BUILDARGCMAKE="-DBUILD_SHARED_LIBS=TRUE"
BUILDTYPECFLAG=""
TARGDIR="${HOME}/hdf5-install"

##
# Fetch the File if $2 is non-zero
# ex:
# fetchfile http://testurl 0
##
fetchfile() {
    SHOULDGET="${2}"
    if [ "${SHOULDGET}" -ne 0 ]; then
        TMPURL="${1}"
        echo -e "\t\t\to Trying ${TMPURL}"
        wget --quiet "${TMPURL}"
        RES="$?"
        if [ $RES -ne 0 ]; then
            echo -e "\t\t\to Failure"
        else
            echo -e "\t\t\to Success"
        fi
        
        return ${RES}
    else
        return 0
    fi
}

dosummary() {
    echo -e ""
    echo -e "HDF5 Versions to be installed:\t${H5VER}"
    if [ "x${HDF5_CFLAGS}" != "x" ]; then
        echo -e "\to HDF5_CFLAGS: ${HDF5_CFLAGS}"
    fi
    if [ "x${HDF5_LDFLAGS}" != "x" ]; then
        echo -e "\to HDF5_LDFLAGS: ${HDF5_LDFLAGS}"
    fi
    if [ "x${H4VER}" != "x" ]; then
        echo -e "HDF4 Version to be installed:\t${H4VER}"
    fi
    if [ "x${DOPAR}" = "xTRUE" ]; then
        echo -e "PNetCDF to be installed:\t${PNETCDFVER}"
    fi
    echo -e "Libraries:\t\t\t${BUILDTYPE}"
    echo -e "Compiler to be used:\t\t${NCCOMP}"
    echo -e "Processors to use:\t\t${NUMPROC}"
    echo -e "Build system:\t\t\t${USEBUILD}"
    echo -e "Debug Symbols:\t\t\t${BUILDDEBUG}"

    echo
    
    echo -e ""
    echo -e "Installing to:\n\to ${TARGDIR}"
    sleep 3
}

dohelp() {
echo -e ""
    echo -e "Usage: $0 [options]"
    echo -e "Options:\n"

    echo -e "\t-a | --h5suffix:\tAddendum to filename, e.g. 'hdf5-1.14.1-2' (default: \"\")"
    echo -e "\t-c | --compiler:\tCompiler to use."
    echo -e "\t\tOptions:\n\t\to gcc\n\t\to clang\n\t\to mpicc"
    echo -e "\t-d | --h5ver:\t\tVersion of HDF5 to install." 
    echo -e "\t-h | --help:\t\tShow this help."
    echo -e "\t-j | --cpus:\t\tNumber of processors to use (default: $(nproc))"
    echo -e "\t-p | --pncver:\t\tVersion of pnetcdf to install (mpicc only)(default: 1.12.3)"
    echo -e "\t-t | --targdir:\t\tTarget directory to install to (default ${TARGDIR})"
    echo -e ""  
    echo -e "Example:"
    echo -e "\t$ $0 -d 1.14.4 -a -3 -j 4 -c gcc -t /usr/local"
    echo -e ""
}

##
# Show help by default, if invoked with no arguemtns.
##
if [ $# -lt 1 ]; then
    dohelp
    exit
fi
ALLARGS="$@"
LONGARGS=$(getopt -o a:c:d:hj:p:t: --long hh5suffix:,compiler:,h5ver:,help,cpus:,pncver:,targdir: -- "$@")

#echo "LONGARGS: ${LONGARGS}"
eval set -- $LONGARGS

while :
do
    case $1 in
        -a | --h5suffix)
            H5VERSUFFIX="${2}"
            shift 2
            ;; 
        -c | --compiler)
            NCCOMP="$2"
            if [ "x${NCCOMP}" = "xmpicc" ]; then
                DOPAR=TRUE
                H5PAROPT="--enable-parallel"
                H5PAROPT_CMAKE="-DHDF5_ENABLE_PARALLEL=TRUE"
                PNETCDFARG="--enable-pnetcdf"                
            fi
            shift 2
            ;;
        -d | --h5ver)
            H5VER=$2
            shift 2
            ;;                    
        -h | --help)
            dohelp
            exit
            ;;
        -j | --cpus)
            NUMPROC="$2"
            shift 2
            ;;
        -p | --pncver)
            PNETCDFVER="$2"
            shift 2
            ;;
        -t | --targdir)
            TARGDIR="$2"
            shift 2
            ;;
       --) shift; break ;;
        *) 
            dohelp
            echo "XXXXX"
            echo $1
            shift;
            break
            ;;
    esac
done


dosummary



##
# HDF5
#
# They have complicated things, so we will try the orginal URL first, and then we will try
# github if the URL fails (as a fallback)
#
## HDF5
if [ "x${H5VER}" != "xa" ]; then
    H5MAJ=$(echo $H5VER | cut -d '.' -f 1)
    H5MIN=$(echo $H5VER | cut -d '.' -f 2)
    H5REV=$(echo $H5VER | cut -d '.' -f 3)

    H5DIR="hdf5-${H5VER}${H5VERSUFFIX}"
    H5DIR_ALT="hdf5_${H5VER}${H5VERSUFFIX}"
    H5FILE="${H5DIR}.tar.bz2"
    H5FILEGZ="${H5DIR}.tar.gz"
    H5FILEGZ_ALT="${H5DIR_ALT}.tar.gz"

    H5URL_DIRECT="https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${H5MAJ}.${H5MIN}/hdf5-${H5VER}/src/${H5FILE}"
    H5URL_DIRECT_GZ="https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${H5MAJ}.${H5MIN}/hdf5-${H5VER}/src/${H5FILEGZ}"
    H5URL_GITHUB="https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-${H5MAJ}.${H5MIN}.${H5REV}${H5VERSUFFIX}.tar.gz"
    H5URL_GITHUB_ALT="https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5_${H5MAJ}.${H5MIN}.${H5REV}${H5VERSUFFIX}.tar.gz"
fi

set +e
##
# Weird Munging so that we can accomodate
# hdf5 changing file naming convention.
##
if [ -f "${H5FILE}" ]; then
    SCFLAG="-jxf"
    SC="2"
    FILEFOUND="TRUE"
fi

if [ -f "${H5FILEGZ}" ]; then
    SCFLAG="-zxf"
    SC="2"
    FILEFOUND="TRUE"
    H5FILE="${H5FILEGZ}"
fi

if [ -f "${H5FILEGZ_ALT}" ]; then
    SCFLAG="-zxf"
    SC="1"
    FILEFOUND="TRUE"
    H5FILE="${H5FILEGZ_ALT}"
fi

if [  "x${FILEFOUND}" = "x" ]; then
    echo -e "\t\to Fetching HDF5"
    wget --quiet "${H5URL_DIRECT}" 

    if [ 1 -ne 0 ]; then SC=2 ; SCFLAG="-jxf" ; H5FILENAME=${H5FILE} ; fi ; fetchfile "${H5URL_DIRECT}" "1" ; FILEGOT=$? 
    if [ ${FILEGOT} -ne 0 ]; then SC=2 ; SCFLAG="-zxf" ; H5FILENAME=${H5FILEGZ} ; fi ; fetchfile "${H5URL_DIRECT_GZ}" "${FILEGOT}" ; FILEGOT=$?  
    if [ ${FILEGOT} -ne 0 ]; then SC=1 ; SCFLAG="-zxf" ; H5FILENAME=${H5FILEGZ} ; fi ; fetchfile "${H5URL_GITHUB}" "${FILEGOT}" ; FILEGOT=$?  
    if [ ${FILEGOT} -ne 0 ]; then SC=1 ; SCFLAG="-zxf" ; H5FILENAME=${H5FILEGZ_ALT} ; fi ; fetchfile "${H5URL_GITHUB_ALT}" "${FILEGOT}" ; FILEGOT=$?

    if [ 0 -ne $FILEGOT ]; then
        echo -e "\t\t\to Failure."
        echo -e ""
        echo -e "Cannot find HDF5 Download URL. Exiting."
        echo -e ""
        exit 8
    fi

    H5FILE="${H5FILENAME}"
else
    H5UNTAR="tar ${SCFLAG} ${H5FILE} -C $(pwd)/${H5DIR} --strip-components=${SC}"
    echo -e "\t\to File ${H5FILE} exists."
fi

####
# Calculate dynamically what the appropriate SC level should be.
###
echo -e "\n\to Examining ${H5FILE} to calculate 'tar' command arguments."
TOP_LEVEL_ITEMS=$(tar tf "${H5FILE}" | awk -F/ '{print $1}' | sort -u)

# Count the number of unique top-level components
COUNT=$(echo "$TOP_LEVEL_ITEMS" | wc -l)

# Determine the number of components to strip
if [[ ${TOP_LEVEL_ITEMS} = "." ]]; then
  SC=2
else
  SC=1
fi

echo -e "\to Calculated SC Level: ${SC}\n"

sleep 3

##
# End SC calculation
## 

set -e
## Configure proper untar command
H5UNTAR="tar ${SCFLAG} ${H5FILE} -C $(pwd)/${H5DIR} --strip-components=${SC}"
## End Munging

### 
# If parallel, we have stuff to do
###
if [ "x$DOPAR" = "xTRUE" ]; then
    PNDIR="pnetcdf-${PNETCDFVER}"
    PNFILE="${PNDIR}.tar.gz"
    PNURL="https://parallel-netcdf.github.io/Release/${PNFILE}"
    if [ ! -f "${PNFILE}" ]; then
        echo -e "\t\to Fetching ${PNURL}"
        wget "${PNURL}"
    else
        echo -e "\t\to File ${PNFILE} exists."

    fi
fi


###
# Build HDF5
###
echo -e "\to HDF5"
mkdir -p "${H5DIR}"

$(echo ${H5UNTAR})

cd "${H5DIR}"

if [ "x${USEBUILD}" = "xac" ]; then
    BUILDTESTSTRING="--disable-tests"
    if [ "x${DONCTESTS}" = "xTRUE" ]; then
        BUILDTESTSTRING=""
    fi

    autoreconf -if 
    H5_API_OP="--with-default-api-version=v110"
    CFLAGS="${CFLAGS} ${HDF5_CFLAGS} -Wno-implicit-function-declaration" CC="${NCCOMP}" LDFLAGS="${LDFLAGS} ${HDF5_LDFLAGS}" ./configure ${BUILDARGAC} "${BUILDTESTSTRING}" --prefix="${TARGDIR}" "${H5PAROPT}" --enable-hl --with-szlib ${H5_API_OP} "${BUILDDEBUGHDF5}"
    sleep 2
    make -j "${NUMPROC}"
    if [ "x${DONCTESTS}" = "xTRUE" ]; then
        make check -j "${NUMPROC}"
    fi
    make install -j "${NUMPROC}" 
    make clean -j "${NUMPROC}"
    cd ..
elif [ "x${USEBUILD}" = "xcmake" ]; then
 
    H5_API_OP="-DDEFAULT_API_VERSION=v110"
    mkdir build
    cd build
    BUILDTESTSTRING="OFF"
    if [ "x${DONCTESTS}" = "xTRUE" ]; then
        BUILDTESTSTRING="ON"
    fi
    LDFLAGS_TMP="${LDFLAGS}"
    LDFLAGS="${LDFLAGS} ${HDF5_LDFLAGS}"
    cmake .. -DHDF5_BUILD_TOOLS=OFF -DBUILD_TESTING="${BUILDTESTSTRING}" -DCMAKE_C_FLAGS="${CFLAGS} ${HDF5_CFLAGS}" ${H5PAROPT_CMAKE} -DCMAKE_C_COMPILER="${NCCOMP}" "${BUILDARGCMAKE}" -DCMAKE_INSTALL_PREFIX="${TARGDIR}" ${H5_API_OP}
    sleep 2
    make -j "${NUMPROC}"
    if [ "x${DONCTESTS}" = "xTRUE" ]; then
        ctest -j "${NUMPROC}"
    fi
    make install -j "${NUMPROC}"
    cd ..
    rm -rf build
    LDFLAGS="${LDFLAGS_TMP}"
    unset LDFLAGS_TMP

fi

if [ "x$DOPAR" = "xTRUE" ]; then
    echo -e "\to pNetCDF"
    tar -zxf "${PNFILE}"
    cd "${PNDIR}"
    autoreconf -if 
    CFLAGS="${CFLAGS}" CC="${NCCOMP}" ./configure ${BUILDARGAC} --prefix="${TARGDIR}"
    make -j "${NUMPROC}"

    make install -j "${NUMPROC}"
    make clean -j "${NUMPROC}"
    cd ..
    rm -rf "${PNDIR}"
fi
##