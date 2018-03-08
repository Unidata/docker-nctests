#!/bin/bash

###
# Manually install hdf4 so that we can run
# those tests as well.
###

cd /root && tar -jxf hdf-4.2.13.tar.bz2 && cd hdf-4.2.13 && ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/usr && make -j 4 && sudo make install
rm -rf hdf-4.2.13


###
# Manually install hdf5 so that we can run
# those tests as well.
###

cd /root && tar -jxf ${HDF5_VER}.tar.bz2 && cd ${HDF5_VER} && ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/usr --with-szlib && make -j 4 && sudo make install
rm -rf ${HDF5_VER}
