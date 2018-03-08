#!/bin/bash###
# Manually install hdf4 so that we can run
# those tests as well.
###


RUN cd hdf-4.2.13 && ./configure --disable-static --enable-shared --disable-netcdf --disable-fortran --prefix=/usr && make -j 4 && sudo make install
RUN rm -rf hdf-4.2.13


###
# Manually install hdf5 so that we can run
# those tests as well.
###

RUN cd ${HDF5_VER} && ./configure --disable-static --enable-shared --disable-fortran --enable-hl --prefix=/usr --with-szlib && make -j 4 && sudo make install
RUN rm -rf ${HDF5_VER}
