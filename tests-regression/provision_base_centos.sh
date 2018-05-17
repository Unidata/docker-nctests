#!/bin/bash

set -e

##
# Install and update core system.
##

yum -y update
yum -y install sudo


##
# Set up a non-root admin to run the tests as.
##

useradd -ms /bin/bash ${CUSER}
echo "${CUSER}:${CUSERPWORD}${RANDOM} " | chpasswd
echo "${CUSER} ALL=NOPASSWD: ALL" >> /etc/sudoers


###
# Install common packages.
###

yum -y install m4 git libjpeg-turbo-devel libcurl-devel wget nano libtool bison autoconf curl zlib-devel zip gcc-gfortran gcc-c++ byacc dos2unix bzip2 flex python2 python2-numpy python2-Cython antlr python2-setuptools python-devel make which file numpy python-setuptools antlr-C++

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
wget https://cmake.org/files/v3.9/cmake-3.9.0.tar.gz
tar -zxf cmake-3.9.0.tar.gz && cd cmake-3.9.0 && ./configure --prefix=/usr && make -j 4 && sudo make install

##
# Some cleanup
##
rm -rf /var/lib/apt/lists/*
