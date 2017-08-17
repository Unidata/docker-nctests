# Usage:
# ncpdq_tst.sh var_nm
ncks -H -C -m --cdl -v ${1} ~/in.nc
ncpdq -O -C -v ${1} ~/in.nc ~/foo.nc
ncks -H -C -m --cdl -v ${1} ~/foo.nc
ncpdq -O -U -C -v ${1} ~/foo.nc ~/foo_upk.nc
ncks -H -C -m --cdl -v ${1} ~/foo_upk.nc
