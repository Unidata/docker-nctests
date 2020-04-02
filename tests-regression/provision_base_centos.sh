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

yum -y install m4 git libjpeg-turbo-devel libcurl-devel wget nano libtool bison autoconf curl zlib-devel zip gcc-gfortran gcc-c++ byacc dos2unix bzip2 flex make which file openssl-devel

##
# Install cmake manually
##
tar -zxf cmake-3.16.4.tar.gz && cd cmake-3.16.4 && ./configure --prefix=/usr && make -j 8 && sudo make install

##
# Some cleanup
##
rm -rf /var/lib/apt/lists/*
