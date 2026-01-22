#!/bin/bash

set -e

##
# Install IntelOne compilers. 
# See the following for installation, usage information.
#
# https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-linux/2023-0/apt.html
# https://www.intel.com/content/www/us/en/docs/dpcpp-cpp-compiler/get-started-guide/2024-0/get-started-on-linux.html
# https://www.intel.com/content/www/us/en/docs/oneapi/programming-guide/2025-1/use-the-setvars-and-oneapi-vars-scripts-with-linux.html
##


# This is only for intel 
echo ""
echo "Installing IntelOne Compiler: icx"
if [ $(uname -m) = "x86_64" ]; then

    sudo apt update
    sudo apt install -y gpg

    sudo wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null

    sudo echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list

    sudo apt update
    sudo apt install -y intel-basekit
else
    echo "IntelOne not available for $(uname -m)"
    echo ""
    exit 1
fi