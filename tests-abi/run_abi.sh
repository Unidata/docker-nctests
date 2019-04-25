#!/bin/bash

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

if [ "x$HELP" != "x" ]; then
    cat README.md
    exit
fi

if [ ! -d "/output" ]; then
    cat README.md
    exit
fi

if [ "x$OLDVER" == "x" ]; then
    cat README.md
    exit
fi

if [ "x$NEWVER" == "x" ]; then
    cat README.md
    exit
fi

if [ "x$DIST" == "xnc" ]; then
    ./run_c_abi_diff.sh
elif [ "x$DIST" == "xnf" ]; then
    ./run_f_abi_diff.sh
elif [ "x$DIST" == "xcxx4" ]; then
    ./run_cxx_abi_diff.sh
else
    echo "Unknown distribution $DIST"
    echo "Options are 'nc', 'nf', 'cxx4'"
    exit 1
fi
exit 0
