#!/bin/bash

set -e
cd /root
###
# Manually install hdf4 so that we can run
# those tests as well.
###

tar -jxf /root/hdf-4.2.14.tar.bz2 && cd /root/hdf-4.2.14 && ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/usr && make -j 4 && sudo make install


cd /root
rm -rf /root/hdf-4.2.14


###
# Manually install hdf5 so that we can run
# those tests as well.
###

tar -jxf /root/hdf5-1.10.4.tar.bz2 && cd /root/hdf5-1.10.4 && ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/usr --with-szlib && make -j 4 && sudo make install

cd /root
rm -rf /root/hdf5-1.10.4

sudo ldconfig
