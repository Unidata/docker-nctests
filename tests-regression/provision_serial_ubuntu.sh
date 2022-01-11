#!/bin/bash

set -e
cd /root
###
# Manually install hdf4 so that we can run
# those tests as well.
###

tar -jxf /root/hdf-4.2.15.tar.bz2 && cd /root/hdf-4.2.15 && autoreconf -if && ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/usr && make -j 8 && sudo make install


cd /root
rm -rf /root/hdf-4.2.15


###
# Manually install hdf5 so that we can run
# those tests as well.
###

# HDF5 1.8.21

HDF5VER=1.8.21

tar -jxf /root/hdf5-${HDF5VER}.tar.bz2 && cd /root/hdf5-${HDF5VER} && autoreconf -if && ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/environments/${HDF5VER} --with-szlib && make -j 8 && sudo make install

cd /root
rm -rf /root/hdf5-1.8.21


# HDF5 1.10.7

HDF5VER=1.10.7

tar -jxf /root/hdf5-${HDF5VER}.tar.bz2 && cd /root/hdf5-${HDF5VER} && autoreconf -if && ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/environments/${HDF5VER} --with-szlib && make -j 8 && sudo make install

cd /root
rm -rf /root/hdf5-${HDF5VER}

# HDF5 1.12.1

HDF5VER=1.12.1

tar -jxf /root/hdf5-${HDF5VER}.tar.bz2 && cd /root/hdf5-${HDF5VER} && autoreconf -if && ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/environments/${HDF5VER} --with-szlib && make -j 8 && sudo make install

cd /root
rm -rf /root/hdf5-${HDF5VER}
