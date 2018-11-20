#!/bin/bash

###
# Install common packages.
###

set -e
cd /root

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
sudo apt-get -y install --no-install-recommends bzip2 g++ gfortran libtool automake autoconf m4 bison flex libcurl4-openssl-dev zlib1g-dev git wget curl libjpeg-dev cmake python-dev cython python-numpy gdb dos2unix antlr libantlr-dev libexpat1-dev libxml2-dev gsl-bin libgsl0-dev udunits-bin libudunits2-0 libudunits2-dev clang zip valgrind python-setuptools make build-essential less unzip patch libsz2 mpich libmpich-dev && sudo apt-get -y autoclean && sudo rm -rf /var/lib/apt/lists/*

###
# Uncompress tarballs.
###

##
# Install cmake manually
##
tar -zxf cmake-3.11.2.tar.gz && cd cmake-3.11.2 && ./configure --prefix=/usr && make -j 4 && sudo make install

###
# Manually install hdf4 so that we can run
# those tests as well.
###

tar -jxf /root/hdf-4.2.13.tar.bz2 && cd /root/hdf-4.2.13 && ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/usr && make -j 4 && sudo make install


for HDFVER in $(cat hdf5_versions.txt); do

    echo "Installing HDF5 Version: ${HDFVER}"
    sleep 1
    HDFFILE="hdf5-${HDFVER}.tar.bz2"
    tar -jxf /root/$HDFFILE && cd /root/"hdf5-${HDFVER}" && ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/environments/serial/"${HDFVER}" --with-szlib && make -j 4 && sudo make install

    cd /root
    rm -rf /root/hdf5-${HDFVER}

done
