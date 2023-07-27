# Utility script to run from host machine to test things.

#!/bin/bash

rm -rf artifacts && time docker build -t unidata/netcdf-tests -f Dockerfile.netcdf-tests . && time docker run --rm -it -v $(pwd)/artifacts:/artifacts -e TESTPROC=8 unidata/netcdf-tests
