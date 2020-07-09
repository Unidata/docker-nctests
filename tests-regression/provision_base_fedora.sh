#!/bin/bash

set -e

##
# Install and update core system.
##

dnf -y update
dnf -y install sudo


##
# Set up a non-root admin to run the tests as.
##

useradd -ms /bin/bash ${CUSER}
echo "${CUSER}:${CUSERPWORD}${RANDOM} " | chpasswd
echo "${CUSER} ALL=NOPASSWD: ALL" >> /etc/sudoers


###
# Install common packages.
###

dnf -y install m4 git libjpeg-turbo-devel libcurl-devel wget nano libtool bison autoconf curl zlib-devel zip gcc-gfortran gcc-c++ byacc dos2unix bzip2 flex python2 python2-numpy python2-Cython antlr python2-setuptools python-devel antlr-C++ openssl-devel file

##
# Install cmake manually
##
tar -zxf cmake-3.16.4.tar.gz && cd cmake-3.16.4 && ./configure --prefix=/usr && make -j 8 && sudo make install

##
# Some cleanup
##
rm -rf /var/lib/apt/lists/*
