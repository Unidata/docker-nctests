#!/bin/bash
#
# Install mpich, after uninstalling current version.
set -e

MPICHVER=4.3.0
TARGDIR="/usr"
NUMPROC=$(nproc)


# Check if 'apt' is available
if ! command -v apt &> /dev/null; then
    echo ""
    echo "Error: 'apt' is not available on the system."
    echo "This command is meant for Debian/Ubuntu-based systems."
    echo ""
    exit 1
fi

dosummary() {
    echo -e ""
    echo -e "MPICH Version to be installed:\t${MPICHVER}"
    echo -e "Processors to use:\t\t${NUMPROC}"

    echo
    
    echo -e ""
    echo -e "Installing to:\to ${TARGDIR}"
    sleep 3
}

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

dohelp() {
    echo -e ""
    echo -e "Usage: $0 [options]"
    echo -e "Options:\n"

    echo -e "\t-j | --cpus:\tNumber of cpus to use to compile (default: ${NUMPROC})"
    echo -e "\t-t | --targdir:\tTarget directory to install to (default: ${TARGDIR})"
    echo -e "\t-v | --version:\tVersion of mpich to install (default: ${MPICHVER})"
    echo -e ""
    echo -e ""
}

if [ $# -lt 1 ]; then
    dohelp
    echo ""
    echo "Press [Return to continue]"
    read
fi

ALLARGS="$@"
LONGARGS=$(getopt -o j:t:v: --long cpus:,targdir:,version: -- "$@")

#echo "LONGARGS: ${LONGARGS}"
eval set -- $LONGARGS

while :
do
    case $1 in
        -j | --cpus)
            NUMPROC="${2}"
            shift 2
            ;;
        -t | --targdir)
            TARGDIR="${2}"
            shift 2
            ;;
        -v | --version)
            MPICHVER="${2}"
            shift 2
            ;;
        --) shift; break;;
        *)
            dohelp
            exit 0
            ;;
    esac
done

dosummary


MPICHMAJ=$(echo $MPICHVER | cut -d '.' -f 1)
MPICHMIN=$(echo $MPICHVER | cut -d '.' -f 2)
MPICHREV=$(echo $MPICHVER | cut -d '.' -f 3)

MPICHDIR="mpich-${MPICHVER}"
MPICHFILE="${MPICHDIR}.tar.gz"
MPICHURL="https://www.mpich.org/static/downloads/${MPICHVER}/${MPICHFILE}"

###
# Fetch the file
###
wget "${MPICHURL}"

###
# Clean up any existing versions.
###
apt update 
apt remove -y mpich
apt autoremove -y

###
# Install Python3 Dependency
###
sudo apt install -y python3

###
# Install mpich
###
tar -zxf "${MPICHFILE}"
pushd "${MPICHDIR}"
./configure --prefix="${TARGDIR}"
make -j "${NUMPROC}"
make install -j "${NUMPROC}"
popd
rm -rf "${MPICHDIR}"
echo "Finished"
