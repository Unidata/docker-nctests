#!/bin/bash

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

dnf -y install m4 git libjpeg-turbo-devel libcurl-devel wget nano libtool bison autoconf curl zlib-devel zip gcc-gfortran gcc-c++ byacc

###
# Pre-fetch tarballs that we'll need.
###

wget http://www.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz
wget http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/parallel-netcdf-1.8.1.tar.bz2
wget https://hdfgroup.org/ftp/HDF/HDF_Current/src/hdf-4.2.13.tar.bz2
wget https://hdfgroup.org/ftp/HDF5/current/src/${HDF5_FILE}

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
