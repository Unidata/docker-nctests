#!/bin/bash

dohelp ()
{
    echo ""
    echo "Usage: $0 -[ix] -p [image name prefix]"
    echo -e "\t -i     Build 32-bit images."
    echo -e "\t -x     Build 64-bit images."
    echo -e "\t -p     Specify an image name. Default: unidata/nctests"
    echo -e "\t -u     Build ubuntu images."
    echo -e "\t -c     Build centos image (64-bit only)."
    echo -e "\t -f     Build fedora image (64-bit only)."
    echo ""
}

DO32=""
DO64=""
DOUBUNTU=""
DOCENTOS=""
DOFEDORA=""

##
# Note that the test Dockerfiles assume unidata/nctests:base[32],
# so we build that tag too, just in case.
##

IPREF="unidata/nctests"

if [ $# -lt 1 ]; then
    dohelp
    exit 0
fi

while getopts "ucfixp:" o; do
    case "${o}" in
        i)
            DO32="TRUE"
            ;;
        x)
            DO64="TRUE"
            ;;
        p)
            IPREF=${OPTARG}
            if [ "x$IPREF" == "x" ]; then
                dohelp
                exit 0
            fi
            ;;
        u)
            DOUBUNTU="TRUE"
            ;;
        c)
            DOCENTOS="TRUE"
            ;;
        f)
            DOFEDORA="TRUE"
            ;;
        *)
            dohelp
            exit 0
    esac
done

echo ""

if [ "x$DO32" == "xTRUE" ]; then

    if [ "x$DOUBUNTU" == "xTRUE" ]; then
        echo "Building 32-bit Ubuntu images."
        echo "Building Base Image"
        docker build -t unidata/nctests:base32 -f Dockerfile.base32 .

        echo "Starting Ubuntu Serial32 Image"
        docker build -t $IPREF:serial32 -f Dockerfile.serial32 . &> ubuntu.serial32.log&
        xterm -T "Ubuntu serial32" -bg black -fg white -geometry 140x20 -e tail -f ubuntu.serial32.log&
        sleep 1

        echo "Starting Ubuntu OpenMPI32 Image"
        docker build -t $IPREF:openmpi32 -f Dockerfile.openmpi32 . &> ubuntu.openmpi32.log&
        xterm -T "Ubuntu openmpi32" -bg black -fg white -geometry 140x20 -e tail -f ubuntu.openmpi32.log&
        sleep 1

        echo "Starting Ubuntu MPICH32 Image"
        docker build -t $IPREF:mpich32 -f Dockerfile.mpich32 . &> ubuntu.mpich32.log&
        xterm -T "Ubuntu mpich32" -bg black -fg white -geometry 140x20 -e tail -f ubuntu.mpich32.log&
        sleep 1
    else
        echo "- Skipping 32-bit Ubuntu"
    fi
fi

echo ""

if [ "x$DO64" == "xTRUE" ]; then


    if [ "x$DOUBUNTU" == "xTRUE" ]; then
        echo "Building 64-bit Ubuntu images."
        echo "Building Centos Base Image"
        docker build -t $IPREF:base -f Dockerfile.base .
        docker build -t unidata/nctests:base -f Dockerfile.base .

        echo "Starting Ubuntu Serial Image"
        docker build -t $IPREF:serial -f Dockerfile.serial . &> ubuntu.serial.log&
        xterm -T "Ubuntu serial" -bg black -fg white -geometry 140x20 -e tail -f ubuntu.serial.log&
        sleep 1

        echo "Starting Ubuntu OpenMPI Ubuntu Image"
        docker build -t $IPREF:openmpi -f Dockerfile.openmpi . &> ubuntu.openmpi.log&
        xterm -T "Ubuntu openmpi" -bg black -fg white -geometry 140x20 -e tail -f ubuntu.openmpi.log&
        sleep 1

        echo "Starting Ubuntu MPICH Ubuntuy Image"
        docker build -t $IPREF:mpich -f Dockerfile.mpich . &> ubuntu.mpich.log&
        xterm -T "Ubuntu mpich" -bg black -fg white -geometry 140x20 -e tail -f ubuntu.mpich.log&
        sleep 1
    else
        echo "- Skipping 64-bit Ubuntu"
    fi

    if [ "x$DOCENTOS" == "xTRUE" ]; then
        echo "Building 64-bit Centos images."
        echo "Building Centos Base Image"
        docker build -t unidata/nctests:base.centos -f Dockerfile.base.centos .

        echo "Starting Centos Serial Image"
        docker build -t $IPREF:serial.centos -f Dockerfile.serial.centos . &> centos.serial.log&
        xterm -T "Centos serial" -bg black -fg white -geometry 140x20 -e tail -f centos.serial.log&
        sleep 1

        echo "Starting Centos OpenMPI Image"
        docker build -t $IPREF:openmpi.centos -f Dockerfile.openmpi.centos . &> centos.openmpi.log&
        xterm -T "Centos openmpi" -bg black -fg white -geometry 140x20 -e tail -f centos.openmpi.log&
        sleep 1

        echo "Starting Centos MPICH Image"
        docker build -t $IPREF:mpich.centos -f Dockerfile.mpich.centos . &> centos.mpich.log&
        xterm -T "Centos mpich" -bg black -fg white -geometry 140x20 -e tail -f centos.mpich.log&
        sleep 1
    else
        echo "- Skipping 64-bit Centos"
    fi

    if [ "x$DOFEDORA" == "xTRUE" ]; then
        echo "Building 64-bit Fedora images."
        echo "Building Fedora Base Image"
        docker build -t unidata/nctests:base.fedora -f Dockerfile.base.fedora .

        echo "Starting Fedora Serial Image"
        docker build -t $IPREF:serial.fedora -f Dockerfile.serial.fedora . &> fedora.serial.log&
        xterm -T "Fedora serial" -bg black -fg white -geometry 140x20 -e tail -f fedora.serial.log&
        sleep 1
    else
        echo "- Skipping 64-bit Fedora"
    fi

fi

echo "Finished"
