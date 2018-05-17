#!/bin/bash

###
# Install common packages.
###


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
sudo apt-get -y install --no-install-recommends bzip2 g++ gfortran libtool automake autoconf m4 bison flex libcurl4-openssl-dev zlib1g-dev git wget curl libjpeg-dev cmake python-dev cython python-numpy gdb dos2unix antlr libantlr-dev libexpat1-dev libxml2-dev gsl-bin libgsl0-dev udunits-bin libudunits2-0 libudunits2-dev clang zip valgrind python-setuptools make build-essential less unzip patch

###
# Uncompress tarballs.
###

tar -zxf szip-2.1.1.tar.gz && rm szip-2.1.1.tar.gz

###
# Build szip, since we will use it for
# all of our projects.
###

cd szip-2.1.1 && ./configure --prefix=/usr --enable-shared --disable-static && make -j 4 && sudo make install -j 4
rm -rf szip-2.1.1

##
# Install cmake manually
##
tar -zxf cmake-3.11.2.tar.gz && cd cmake-3.11.2 && ./configure --prefix=/usr && make -j 4 && sudo make install

##
# Some cleanup
##
rm -rf /var/lib/apt/lists/*
