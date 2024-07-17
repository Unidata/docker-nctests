#!/bin/bash

set -e
cd /root
###
# Manually install hdf4 so that we can run
# those tests as well.
###

#tar -jxf /root/hdf-4.2.15.tar.bz2 && cd /root/hdf-4.2.15 && autoreconf -if && ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/usr && make -j 8 && sudo make install


HDF5VER=1.14.2

tar -jxf /root/hdf5-${HDF5VER}.tar.bz2 && cd /root/hdf5-${HDF5VER} && autoreconf -if && ./configure --disable-static --enable-shared --disable-tests --disable-fortran --enable-hl --prefix=/environments/${HDF5VER} --with-szlib && make -j $(nproc) && sudo make install

cd /root
rm -rf /root/hdf5-${HDF5VER}

##
# Some cleanup
##
rm -rf /var/lib/apt/lists/*

