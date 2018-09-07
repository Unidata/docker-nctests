#!/bin/bash

set -e
cd /root

export PATH=/usr/lib64/openmpi/bin:$PATH
export PATH=/usr/lib64/mpich-3.2/bin:$PATH

###
# Manually install hdf4 so that we can run
# those tests as well.
###

tar -jxf /root/hdf-4.2.13.tar.bz2 && cd /root/hdf-4.2.13 && CC=mpicc ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/usr && make -j 4 && make install

cd /root
rm -rf /root/hdf-4.2.13


###
# Manually install hdf5 so that we can run
# those tests as well.
###

CFLAGS="-Wno-format-security"
tar -jxf /root/hdf5-1.10.3.tar.bz2 && cd /root/hdf5-1.10.3 && CC=mpicc ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/usr --with-szlib --enable-parallel && make -j 4 && make install

cd /root
rm -rf /root/hdf5-1.10.3

###
# Manually install pnetcdf so that we can
# run pnetcdf tests.
###

tar -zxf /root/parallel-netcdf-1.9.0.tar.gz && cd /root/parallel-netcdf-1.9.0 && CPPFLAGS=-fPIC CC=mpicc ./configure --prefix=/usr --disable-fortran && make -j 4 -k && make install

cd /root
rm -rf parallel-netcdf-1.9.0
sudo ldconfig
