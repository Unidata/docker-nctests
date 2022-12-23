#!/bin/bash

rm -rf artifacts && time docker build -t unidata/netcdf-tests -f Dockerfile.netcdf-tests . --no-cache && time docker run --rm -it -v $(pwd)/artifacts:/artifacts -e TESTPROC=12 unidata/netcdf-tests
