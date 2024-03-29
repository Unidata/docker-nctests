#!/bin/bash

dohelp ()
{
    echo ""
    echo "Usage: $0 [-i|-x]"
    echo -e "\t -i     Push 32-bit images."
    echo -e "\t -x     Push 64-bit images."
    echo -e "\t -u     Push ubuntu images."
    echo -e "\t -f     Push fedora image (64-bit only)."

    echo ""
}

DO32=""
DO64=""
DOUBUNTU=""
DOCENTOS=""
DOFEDORA=""

if [ $# -lt 1 ]; then
    dohelp
    exit 0
fi

while getopts "ixucf" o; do
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
        f)
            DOFEDORA="TRUE"
            ;;
        *)
            dohelp
            exit 0
    esac
done

if [ "x$DO32" == "xTRUE" ]; then
    if [ "x$DOUBUNTU" == "xTRUE" ]; then
        echo "Pushing 32-bit ubuntu images."
        docker push unidata/nctests:base32
        docker push unidata/nctests:serial32
        docker push unidata/nctests:openmpi32
        docker push unidata/nctests:mpich32
    else
        echo "- Skipping 32-bit Ubuntu"
    fi
fi

if [ "x$DO64" == "xTRUE" ]; then
    if [ "x$DOUBUNTU" == "xTRUE" ]; then
        echo "Pushing 64-bit Ubuntu images."
        docker push unidata/nctests:base
        docker push unidata/nctests:serial
        docker push unidata/nctests:openmpi
        docker push unidata/nctests:mpich
    else
        echo "- Skipping 64-bit Ubuntu"
    fi

    if [ "x$DOFEDORA" == "xTRUE" ]; then
        echo "Pushing 64-bit Fedora images."
        docker push unidata/nctests:base.fedora
        docker push unidata/nctests:serial.fedora
    else
        echo "- Skipping 64-bit Fedora"
    fi

fi

echo "Finished"
