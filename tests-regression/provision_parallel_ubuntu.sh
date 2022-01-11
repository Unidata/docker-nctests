#!/bin/bash

set -e
cd /root


###
# Manually install hdf4 so that we can run
# those tests as well.
###

tar -jxf /root/hdf-4.2.15.tar.bz2 && cd /root/hdf-4.2.15 && CC=mpicc ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/usr && make -j 8 && sudo make install

cd /root
rm -rf /root/hdf-4.2.15


###
# Manually install hdf5 so that we can run
# those tests as well.
###
CFLAGS="-Wno-format-security"

#
# 1.8.21
#
HDF5VER=1.8.21
tar -jxf /root/hdf5-${HDF5VER}.tar.bz2 && cd /root/hdf5-${HDF5VER} && autoreconf -if && CC=mpicc ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/environments/${HDF5VER} --with-szlib --enable-parallel && make -j 8 && sudo make install

cd /root
rm -rf /root/hdf5-${HDF5VER}


#
# 1.10.7
#
HDF5VER=1.10.7
tar -jxf /root/hdf5-${HDF5VER}.tar.bz2 && cd /root/hdf5-${HDF5VER} && autoreconf -if && CC=mpicc ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/environments/${HDF5VER} --with-szlib --enable-parallel && make -j 8 && sudo make install

cd /root
rm -rf /root/hdf5-${HDF5VER}

#
# 1.12.1
#
HDF5VER=1.12.1
tar -jxf /root/hdf5-${HDF5VER}.tar.bz2 && cd /root/hdf5-${HDF5VER} && autoreconf -if && CC=mpicc ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/environments/${HDF5VER} --with-szlib --enable-parallel && make -j 8 && sudo make install

cd /root
rm -rf /root/hdf5-${HDF5VER}



###
# Manually install pnetcdf so that we can
# run pnetcdf tests.
###

tar -zxf /root/pnetcdf-1.11.0.tar.gz && cd /root/pnetcdf-1.11.0 && CPPFLAGS=-fPIC CC=mpicc ./configure --prefix=/usr --disable-fortran --enable-relax-coord-bound && make -j 8 -k && sudo make install

cd /root
rm -rf pnetcdf-1.11.0
