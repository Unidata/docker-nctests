#!/bin/bash
# Simple, brute force build

set -e

echo -e "Building and Pushing images (linux/arm64,linux/amd64), no-cache"
echo -e "==============================================================="

echo -e ""
echo -e "\to Base"
sleep 2
time docker build --platform linux/arm64,linux/amd64 -t docker.unidata.ucar.edu/nctests:base -f Dockerfile.base . --no-cache --push

echo -e ""
echo -e "\to Serial"
sleep 2 
time docker build --platform linux/arm64,linux/amd64 -t docker.unidata.ucar.edu/nctests:serial -f Dockerfile.serial . --no-cache --push

echo -e ""
echo -e "\to MPICH"
sleep 2 
time docker build --platform linux/arm64,linux/amd64 -t docker.unidata.ucar.edu/nctests:mpich -f Dockerfile.mpich . --no-cache --push



