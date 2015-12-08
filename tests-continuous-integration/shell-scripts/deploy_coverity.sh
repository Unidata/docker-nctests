#!/bin/bash

# This script is used to deploy a coverity install in a linux
# machine, most likely a VM, as well as install the 'cov-scan-build'
# script.  The only argument is the tarball to deploy.


INFILE=$1
TARGDIR=~/coverity

if [ $# -lt 1 ]; then
    echo "You must specify a tarball to install from."
    exit 0
fi

echo "Installing from: $INFILE"

mkdir -p $TARGDIR

tar -zxf $INFILE -C $TARGDIR --strip-components=1

echo "export PATH=$TARGDIR/bin:$PATH" >> ~/.bashrc
cp cov-scan-build.sh $TARGDIR/bin

. $HOME/.bashrc

if hash cov-scan-build.sh 2>/dev/null; then
    echo "Success.  Run cov-scan-build.sh to generate a Coverity report."
else
    echo "Success. Source your ~/.bashrc and run cov-scan-build.sh to generate a Coverity report."
fi
