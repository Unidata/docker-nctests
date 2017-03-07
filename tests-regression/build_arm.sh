#!/bin/bash

set -e

echo "Building base.arm"

docker build -t unidata/nctests:base.arm -f Dockerfile.base.arm .

echo "Building serial.arm"

docker build -t unidata/nctests:serial.arm -f Dockerfile.serial.arm .

echo "Building openmpi.arm"

docker build -t unidata/nctests:openmpi.arm -f Dockerfile.openmpi.arm .

echo "Building mpich.arm"

docker build -t unidata/nctests:mpich.arm -f Dockerfile.mpich.arm .

echo "Finished"
