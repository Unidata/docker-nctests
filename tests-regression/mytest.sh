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
docker run --rm -it -v $(pwd):/netcdf-c unidata/nctests:nco
git reset --hard


#docker run --rm -it -v $(pwd):/netcdf-c unidata/nctests:nco
