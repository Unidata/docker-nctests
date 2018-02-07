#!/bin/bash

#set -e

function ERR {
    RES=$?
    if [ $RES -ne 0 ]; then
        echo "Error found: $RES"
        git reset --hard
        exit $RES
    fi

}

# Below can be modified as need be.
rm -rf build
mkdir -p build
cd build
cmake .. -DENABLE_TESTS=OFF; ERR
make -j 4; ERR
cd ncdump
./ncdump ~/Desktop/test.nc; ERR
#./ncdump -h https://data.nodc.noaa.gov/thredds/dodsC/ioos/sccoos/scripps_pier/scripps_pier-2016.nc; ERR
cd ..
cd ..
rm -rf build
git reset --hard


#docker run --rm -it -v $(pwd):/netcdf-c unidata/nctests:nco
