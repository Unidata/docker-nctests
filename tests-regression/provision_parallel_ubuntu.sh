#!/bin/bash

set -e
cd /root

###
# Manually install hdf5 so that we can run
# those tests as well.
###
CFLAGS="-Wno-format-security"

##
# Ok, currently mpich is broken so we will need to install it manually.
##
# 4.2.3
##
#tar -zxf /root/mpich-4.2.3.tar.gz && cd /root/mpich-4.2.3 && ./configure --prefix=/usr && make -j $(nproc) && sudo make install -j $(nproc)

#cd /root
#rm -rf /root/mpich-4.2.3
sudo apt update && sudo apt install -y mpich
#
# 1.14.3
#
HDF5VER=1.14.3
#tar -jxf /root/hdf5-${HDF5VER}.tar.bz2 && cd /root/hdf5-${HDF5VER} && autoreconf -if && CC=mpicc ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/environments/${HDF5VER} --with-szlib --enable-parallel && make -j $(nproc) && sudo make install

#cd /root
#rm -rf /root/hdf5-${HDF5VER}

###
# Manually install hdf4 so that we can run
# those tests as well.
###

#tar -jxf /root/hdf4.3.0.tar.gz && cd /root/hdf-hdf4.3.0 && CC=mpicc ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/environments/${HDF5VER} && make -j $(nproc) && sudo make install

#cd /root
#rm -rf /root/hdf-4.3.0


###
# Manually install pnetcdf so that we can
# run pnetcdf tests.
###

#tar -zxf /root/pnetcdf-1.12.3.tar.gz && cd /root/pnetcdf-1.12.3 && CPPFLAGS=-fPIC CC=mpicc ./configure --prefix=/usr --disable-fortran --enable-relax-coord-bound && make -j $(nproc) -k && sudo make install

#cd /root
#rm -rf pnetcdf-1.12.3

##
# Some cleanup
##
rm -rf /var/lib/apt/lists/*
