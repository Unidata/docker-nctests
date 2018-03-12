#!/bin/bash

set -e
cd /root


###
# Manually install hdf4 so that we can run
# those tests as well.
###

tar -jxf /root/hdf-4.2.13.tar.bz2 && cd /root/hdf-4.2.13 && CC=$(which mpicc) ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/usr && make -j 4 && sudo make install

cd /root
rm -rf /root/hdf-4.2.13


###
# Manually install hdf5 so that we can run
# those tests as well.
###

CFLAGS="-Wno-format-security"
tar -jxf /root/hdf5-1.10.1.tar.bz2 && cd /root/hdf5-1.10.1 && CC=$(which mpicc) ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/usr --with-szlib --enable-parallel && make -j 4 && sudo make install

cd /root
rm -rf /root/hdf5-1.10.1

###
# Manually install pnetcdf so that we can
# run pnetcdf tests.
###

CFLAGS=""
CPPFLAGS="-fPIC"
tar -jxf /root/parallel-netcdf-1.8.1.tar.bz2 && cd /root/parallel-netcdf-1.8.1 && CC=$(which mpicc) ./configure --prefix=/usr --disable-fortran && make -j 4 -k && sudo make install

cd /root
rm -rf parallel-netcdf-1.8.1
