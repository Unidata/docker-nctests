#!/bin/bash

set -e

###
# Manually install hdf4 so that we can run
# those tests as well.
###

tar -jxf /root/hdf-4.2.13.tar.bz2 && cd /root/hdf-4.2.13 && ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/usr && make -j 4 && sudo make install
rm -rf /root/hdf-4.2.13


###
# Manually install hdf5 so that we can run
# those tests as well.
###

tar -jxf /root/${HDF5_FILE} && cd /root/${HDF5_VER} && ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/usr --with-szlib && make -j 4 && sudo make install
rm -rf ${HDF5_VER}
