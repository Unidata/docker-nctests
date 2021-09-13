#!/bin/bash

###
# Install common packages.
###
set -e

apt-get update
apt-get -y upgrade
apt-get -y install --no-install-recommends sudo

##
# Set up a non-root admin to run the tests as.
##

useradd -ms /bin/bash ${CUSER}
adduser ${CUSER} sudo
echo "${CUSER}:${CUSERPWORD}${RANDOM} " | chpasswd
echo "${CUSER} ALL=NOPASSWD: ALL" >> /etc/sudoers

###
# Install some basics.
###
sudo apt-get -y install --no-install-recommends bzip2 g++ gfortran libtool automake autoconf m4 bison flex libcurl4-openssl-dev zlib1g-dev git wget curl libjpeg-dev cmake python-dev gdb dos2unix gsl-bin libgsl0-dev udunits-bin libudunits2-0 libudunits2-dev clang zip valgrind python-setuptools make build-essential less unzip patch libsz2 libaec-dev libssl-dev

###
# Uncompress tarballs.
###

##
# Install cmake manually
##
tar -zxf cmake-3.16.4.tar.gz && cd cmake-3.16.4 && ./configure --prefix=/usr && make -j 8 && sudo make install -j 8

##
# Some cleanup
##
rm -rf /var/lib/apt/lists/*
