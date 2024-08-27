#!/bin/bash

set -e
cd /root

###
# Manually install hdf5 so that we can run
# those tests as well.
###

HDF5VER=1.14.3

tar -jxf /root/hdf5-${HDF5VER}.tar.bz2 && cd /root/hdf5-${HDF5VER} && autoreconf -if && ./configure --disable-static --enable-shared --disable-tests --disable-fortran --enable-hl --prefix=/environments/${HDF5VER} --with-szlib && make -j $(nproc) && sudo make install

cd /root
rm -rf /root/hdf5-${HDF5VER}

###
# Manually install hdf4 so that we can run
# those tests as well.
###
tar -zxf /root/hdf4.3.0.tar.gz && cd /root/hdf4-hdf4.3.0 && autoreconf -if && ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/environments/${HDF5VER} && make -j $(nproc) && make sudo make install

##
# Some cleanup
##
rm -rf /var/lib/apt/lists/*

