##
#!/bin/bash
#
# Download the files so that each build can copy locally.
##

wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.14/hdf5-1.14.2/src/hdf5-1.14.2.tar.bz2
wget https://parallel-netcdf.github.io/Release/pnetcdf-1.12.3.tar.gz

H4VER=4.3.0
H4DIR="hdf4-hdf${H4VER}"
H4FILE="hdf${H4VER}.tar.gz"
H4URL="https://github.com/HDFGroup/hdf4/archive/refs/tags/${H4FILE}"

wget "${H4URL}"
wget https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz
