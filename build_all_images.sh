#!/bin/bash

dohelp ()
{
    echo ""
    echo "Usage: $0 -[ix] -p [image name prefix]"
    echo -e "\t -i     Build 32-bit images."
    echo -e "\t -x     Build 64-bit images."
    echo -e "\t -p     Specify an image name. Default: wardf/nctests"
    echo ""
}

DO32=""
DO64=""

##
# Note that the test Dockerfiles assume wardf/nctests:base[32],
# so we build that tag too, just in case.
##

IPREF="wardf/nctests"

if [ $# -lt 1 ]; then
    dohelp
    exit 0
fi

while getopts "ixp:" o; do
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
        *)
            dohelp
            exit 0
    esac
done

if [ "x$DO32" == "xTRUE" ]; then
    echo "Building 32-bit images."
    echo "Building Base Image"
    docker build -t $IPREF:base32 -f Dockerfile.base32 .
    docker build -t wardf/nctests:base32 -f Dockerfile.base32 .

    echo "Starting Serial32 Image"
    docker build -t $IPREF:serial32 -f Dockerfile.serial32 . &> serial32.log&
    xterm -T serial32 -bg black -fg white -geometry 140x20+10+10 -e tail -f serial32.log&
    sleep 1

    echo "Starting OpenMPI32 Image"
    docker build -t $IPREF:openmpi32 -f Dockerfile.openmpi32 . &> openmpi32.log&
    xterm -T openmpi32 -bg black -fg white -geometry 140x20+10+10 -e tail -f openmpi32.log&
    sleep 1

    echo "Starting MPICH32 Image"
    docker build -t $IPREF:mpich32 -f Dockerfile.mpich32 . &> mpich32.log&
    xterm -T mpich32 -bg black -fg white -geometry 140x20+10+10 -e tail -f mpich32.log&
    sleep 1
fi

if [ "x$DO64" == "xTRUE" ]; then
    echo "Building 64-bit images."
    echo "Building Base Image"
    docker build -t $IPREF:base -f Dockerfile.base .
    docker build -t wardf/nctests:base -f Dockerfile.base .

    echo "Starting Serial Image"
    docker build -t $IPREF:serial -f Dockerfile.serial . &> serial.log&
    xterm -T serial -bg black -fg white -geometry 140x20+10+10 -e tail -f serial.log&
    sleep 1

    echo "Starting OpenMPI Image"
    docker build -t $IPREF:openmpi -f Dockerfile.openmpi . &> openmpi.log&
    xterm -T openmpi -bg black -fg white -geometry 140x20+10+10 -e tail -f openmpi.log&
    sleep 1

    echo "Starting MPICH Image"
    docker build -t $IPREF:mpich -f Dockerfile.mpich . &> mpich.log&
    xterm -T mpich -bg black -fg white -geometry 140x20+10+10 -e tail -f mpich.log&
    sleep 1

fi

echo "Finished"
