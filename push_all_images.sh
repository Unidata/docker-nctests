#!/bin/bash

dohelp ()
{
    echo ""
    echo "Usage: $0 [-i|-x]"
    echo -e "\t -i     Push 32-bit images."
    echo -e "\t -x     Push 64-bit images."
    echo ""
}

DO32=""
DO64=""

if [ $# -lt 1 ]; then
    dohelp
    exit 0
fi

while getopts "ix" o; do
    case "${o}" in
        i)
            DO32="TRUE"
            ;;
        x)
            DO64="TRUE"
            ;;
        *)
            dohelp
            exit 0
    esac
done

if [ "x$DO32" == "xTRUE" ]; then
    echo "Pushing 32-bit images."
    docker push wardf/nctests:base32
    docker push wardf/nctests:serial32
    docker push wardf/nctests:openmpi32
    docker push wardf/nctests:mpich32
fi

if [ "x$DO64" == "xTRUE" ]; then
    echo "Pushing 64-bit images."
    docker push wardf/nctests:base
    docker push wardf/nctests
    docker push wardf/nctests:serial
    docker push wardf/nctests:openmpi
    docker push wardf/nctests:mpich

fi

echo "Finished"
