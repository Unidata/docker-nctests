#!/bin/bash

###
# Install common packages.
###
set -e

apt update
apt -y upgrade
apt -y install --no-install-recommends sudo adduser
apt -y install ca-certificates
##
# Set up a non-root admin to run the tests as.
##

CUSERPASSWORD=${RANDOM}${RANDOM}${RANDOM}
useradd -ms /bin/bash ${CUSER}
adduser ${CUSER} sudo
echo "${CUSER}:${CUSERPWORD}${RANDOM} " | chpasswd
echo "${CUSER} ALL=NOPASSWD: ALL" >> /etc/sudoers

###
# Install some basics.
###
sudo apt-get -y install --no-install-recommends bzip2 g++ gfortran libtool automake autoconf m4 bison flex libcurl4-openssl-dev zlib1g-dev git wget curl libjpeg-dev cmake gdb dos2unix gsl-bin libgsl0-dev udunits-bin libudunits2-0 libudunits2-dev clang zip valgrind python-setuptools-doc make build-essential less unzip patch libsz2 libaec-dev libssl-dev cmake libxml2 libxml2-dev mpich nano libmpich-dev graphviz doxygen

###
# Custom mpich installs
###
sudo bash -x  /root/install_mpich.sh -v 4.3.0 -j $(nproc)


##
# Some cleanup
##
rm -rf /var/lib/apt/lists/*
