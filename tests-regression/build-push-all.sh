#!/bin/bash
# 
# Utility script to build for 3 architectures.

set -e

echo -e ""
echo -e "Building unidata/nctests for the following architectures:"
echo -e "\to linux/arm64"
echo -e "\to linux/amd64"
echo -e "\to linux/s390x"
echo ""
echo "!!! This will take a while! Up to two hours or more! !!!"
echo ""
echo -e "[Press Return to Continue]"
echo ""
read

time docker build -t unidata/nctests:1.13.4 -f Dockerfile.nctests --platform linux/arm64,linux/amd64,linux/s390x . --push

