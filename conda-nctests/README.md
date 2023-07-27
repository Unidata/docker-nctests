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

### Source Code

#### NetCDF-C

* `CBRANCH` - Branch of `netCDF-C` to test. **Default value: main**
* `DIST_C` - Generate C source-code artifacts. **Default value: ON**
* `DISTCHECK_C` - Whether to perform `make distcheck` on the C library.  **Default value: OFF**

### System Resource Options

* `TESTPROC` - The number of processors to use. **Default value: 1**

### Build System Options

* `USE_CC` - The C compiler to use.  Options are `gcc`, `clang`, `mpi`.  **Default value: gcc**
* `USEAC` - Run tests using the `autotools`-based build system. **Default value: TRUE**
* `USECMAKE` - Run tests using the `cmake`-based build system. **Default value: TRUE**

## Examples

    $ docker run --rm -it -e TESTPROC=8 -v $(pwd)/artifacts:/artifacts unidata/netcdf-test 