# Docker-based Tests and Artifact Generation

`docker.unidata.ucar.edu/netcdf-tests`

This project is used to run tests and generate artifacts for `netCDF-C`, `netCDF-Fortran` and `netCDF-CXX4`.  It uses `docker` for containerization, and allows us to build and run tests under emulation using the `--platform` director for compatible `docker` installs. 

## Building

### Docker Build

    $ docker build -t unidata/netcdf-tests -f Dockerfile.netcdf-tests .

### Docker Buildx (multi-arch)

    $ time docker buildx build --push --platform linux/arm64/v8,linux/amd64 -t unidata/netcdf-tests -f Dockerfile.netcdf-tests .
## Usage

### Artifacts

If you want artifacts to be generated in a way that's easily accessible, you'll need to pass the following argument when invoking docker:

*  `-v [host directory]:/artifacts`

## Arguments



### System Resource Options

* `DOHELP` - Show `HELP` info, exit 0. 
* `TESTPROC` - The number of processors to use. **Default value: 1**

### Build System Options

* `USE_CC` - The C compiler to use.  Options are `gcc`, `clang`, `mpicc`.  **Default value: gcc**
* `USEAC` - Run tests using the `autotools`-based build system. **Default value: TRUE**
* `USECMAKE` - Run tests using the `cmake`-based build system. **Default value: TRUE**
* `H5VER` - Version of HDF5 to install.  **Default value: 1.12.2**

### Source-Code Specific

#### NetCDF-C

* `CBRANCH` - Branch of `netCDF-C` to test. **Default value: `main`**
* `DIST_C` - Generate source-code artifacts via `make dist`. **Default value: TRUE**
* `DISTCHECK_C` - Whether to run `make distcheck`. **Default Value: FALSE**
## Examples

    $ docker run --rm -it -e TESTPROC=8 -v $(pwd)/artifacts:/artifacts docker.undiata.ucar.edu/netcdf-tests

    $ docker run --rm -it -e TESTPROC=4 -v $(pwd)/artifacts:/artifacts -e H5VER=1.12.2 -e CBRANCH=v4.9.2 -e USEAC=FALSE docker.unidata.ucar.edu/netcdf-tests