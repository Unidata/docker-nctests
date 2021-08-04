#!/bin/bash

dohelp ()
{
    echo ""
    echo "Usage: $0 -[ix] -p [image name prefix]"
    echo -e "\\t -i     Build 32-bit images."
    echo -e "\\t -x     Build 64-bit images."
    echo -e "\\t -u     Build ubuntu images."
    echo -e "\\t -c     Build centos image (64-bit only)."
    echo -e "\\t -f     Build fedora image (64-bit only)."
    echo -e ""
    echo -e "\\t -b     Build base image(s) only."
    echo ""
    echo ""
}

DO32=""
DO64=""
DOUBUNTU=""
DOCENTOS=""
DOFEDORA=""
DOBASEONLY=""


if [ $# -lt 1 ]; then
    dohelp
    exit 0
fi

while getopts "ucfixb" o; do
    case "${o}" in
        i)
            DO32="TRUE"
            ;;
        x)
            DO64="TRUE"
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
        b)
            DOBASEONLY="TRUE"
            ;;
        *)
            dohelp
            exit 0
    esac
done

echo ""

# Do a block of base images only.

if [ "x$DOBASEONLY" == "xTRUE" ]; then
    echo "Building Base Images"
    if [ "x$DO32" == "xTRUE" ]; then
        if [ "x$DOUBUNTU" == "xTRUE" ]; then
            echo "Building unidata/nctests:base32"
            docker build -t unidata/nctests:base32 -f Dockerfile.base32 . --no-cache &> ubuntu.base32.log&
            xterm -T "Ubuntu base32" -bg black -fg white -geometry 140x20 -e tail -f ubuntu.base32.log&
            sleep 1
        fi
    fi

    if [ "x$DO64" == "xTRUE" ]; then
        if [ "x$DOUBUNTU" == "xTRUE" ]; then
            echo "Building unidata/nctests:base"
            docker build -t unidata/nctests:base -f Dockerfile.base . --no-cache &> ubuntu.base.log&
            xterm -T "Ubuntu base" -bg black -fg white -geometry 140x20 -e tail -f ubuntu.base.log&
            sleep 1
        fi

        if [ "x$DOCENTOS" == "xTRUE" ]; then
            echo "Building unidata/nctests:base.centos"
            docker build -t unidata/nctests:base.centos -f Dockerfile.base.centos . --no-cache &> base.centos.log&
            xterm -T "Centos base" -bg black -fg white -geometry 140x20 -e tail -f base.centos.log&
            sleep 1
        fi

        if [ "x$DOFEDORA" == "xTRUE" ]; then
            echo "Building unidata/nctests:base.fedora"
            docker build -t unidata/nctests:base.fedora -f Dockerfile.base.fedora . --no-cache &> base.fedora.log&
            xterm -T "Fedora base" -bg black -fg white -geometry 140x20 -e tail -f base.fedora.log&
            sleep 1
        fi


    fi

    exit 0
fi



if [ "x$DO32" == "xTRUE" ]; then

    if [ "x$DOUBUNTU" == "xTRUE" ]; then
        echo "Building 32-bit Ubuntu images."
        echo "Building Base Image"
        docker build -t unidata/nctests:base32 -f Dockerfile.base32 .

        echo "Starting Ubuntu Serial32 Image"
        docker build -t unidata/nctests:serial32 -f Dockerfile.serial32 . --no-cache &> ubuntu.serial32.log&
        xterm -T "Ubuntu serial32" -bg black -fg white -geometry 140x20 -e tail -f ubuntu.serial32.log&
        sleep 1

        echo "Starting Ubuntu OpenMPI32 Image"
        docker build -t unidata/nctests:openmpi32 -f Dockerfile.openmpi32 . --no-cache &> ubuntu.openmpi32.log&
        xterm -T "Ubuntu openmpi32" -bg black -fg white -geometry 140x20 -e tail -f ubuntu.openmpi32.log&
        sleep 1

        echo "Starting Ubuntu MPICH32 Image"
        docker build -t unidata/nctests:mpich32 -f Dockerfile.mpich32 . --no-cache  &> ubuntu.mpich32.log&
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
        docker build -t unidata/nctests:base -f Dockerfile.base .

        echo "Starting Ubuntu Serial Image"
        docker build -t unidata/nctests:serial -f Dockerfile.serial . --no-cache  &> ubuntu.serial.log&
        xterm -T "Ubuntu serial" -bg black -fg white -geometry 140x20 -e tail -f ubuntu.serial.log&
        sleep 1

        echo "Starting Ubuntu OpenMPI Ubuntu Image"
        docker build -t unidata/nctests:openmpi -f Dockerfile.openmpi . --no-cache  &> ubuntu.openmpi.log&
        xterm -T "Ubuntu openmpi" -bg black -fg white -geometry 140x20 -e tail -f ubuntu.openmpi.log&
        sleep 1

        echo "Starting Ubuntu MPICH Ubuntuy Image"
        docker build -t unidata/nctests:mpich -f Dockerfile.mpich . --no-cache  &> ubuntu.mpich.log&
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
        docker build -t unidata/nctests:serial.centos -f Dockerfile.serial.centos . --no-cache &> centos.serial.log&
        xterm -T "Centos serial" -bg black -fg white -geometry 140x20 -e tail -f centos.serial.log&
        sleep 1

        echo "Starting Centos OpenMPI Image"
        docker build -t unidata/nctests:openmpi.centos -f Dockerfile.openmpi.centos . --no-cache &> centos.openmpi.log&
        xterm -T "Centos openmpi" -bg black -fg white -geometry 140x20 -e tail -f centos.openmpi.log&
        sleep 1

        echo "Starting Centos MPICH Image"
        docker build -t unidata/nctests:mpich.centos -f Dockerfile.mpich.centos . --no-cache &> centos.mpich.log&
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
        docker build -t unidata/nctests:serial.fedora -f Dockerfile.serial.fedora . --no-cache  &> fedora.serial.log&
        xterm -T "Fedora serial" -bg black -fg white -geometry 140x20 -e tail -f fedora.serial.log&
        sleep 1
    else
        echo "- Skipping 64-bit Fedora"
    fi

fi

echo "Finished"
