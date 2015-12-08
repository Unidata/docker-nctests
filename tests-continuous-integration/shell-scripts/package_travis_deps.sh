#####
#!/bin/bash
#
# This is a utility script, meant to be run on a 'precise pangolin' VM
# to create a tarball of dependencies/software for running netcdf tests
# via travis-ci.  It assumes that the packages have been installed, in /usr,
# before running.
#
# Once the tarball is created, it will need to be hosted somewhere, and
# the location will need to be reflected in the .travis.yml file in the
# root of the netcdf-c project on github.
#
# Once created, copy to /web/content/downloads/netcdf/ftp
#####

TARBALL="travisdeps.tar.bz2"
rm -f $TARBALL

set -x
set -e

##
# Define the files we need to package.
##

CMAKEFILES="/usr/doc/cmake-3.2 /usr/share/cmake-3.2 /usr/bin/cmake /usr/bin/ctest /usr/bin/cpack"

HDFFILES="/usr/lib/libhdf4.settings /usr/lib/libdf* /usr/lib/libmfhdf* /usr/include/hdf2netcdf.h /usr/include/local_nc.h /usr/include/mfhdf.h /usr/include/hdf4_netcdf.h /usr/include/mfhdfi.h /usr/include/mfdatainfo.h /usr/include/atom.h /usr/include/bitvect.h /usr/include/cdeflate.h /usr/include/cnbit.h /usr/include/cnone.h /usr/include/cskphuff.h /usr/include/crle.h /usr/include/cszip.h /usr/include/df.h /usr/include/dfan.h /usr/include/dfi.h /usr/include/dfgr.h /usr/include/dfrig.h /usr/include/dfsd.h /usr/include/dfstubs.h /usr/include/dfufp2i.h /usr/include/dynarray.h /usr/include/H4api_adpt.h /usr/include/h4config.h /usr/include/hbitio.h /usr/include/hchunks.h /usr/include/hcomp.h /usr/include/hcompi.h /usr/include/hconv.h /usr/include/hdf.h /usr/include/hdfi.h /usr/include/herr.h /usr/include/hfile.h /usr/include/hkit.h /usr/include/hlimits.h /usr/include/hproto.h /usr/include/hntdefs.h /usr/include/htags.h /usr/include/linklist.h /usr/include/mfan.h /usr/include/mfgr.h /usr/include/mstdio.h /usr/include/tbbt.h /usr/include/vattr.h /usr/include/vg.h /usr/include/hdatainfo.h"

HDF5FILES="/usr/lib/libhdf5.settings /usr/lib/libhdf5* /usr/include/hdf5.h /usr/include/hdf5_hl.h /usr/include/H5*.h"

tar -jcvf $TARBALL $CMAKEFILES $HDFFILES $HDF5FILES

ls -alh $TARBALL
