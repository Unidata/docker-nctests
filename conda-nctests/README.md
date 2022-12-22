# Docker Tests

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

### Resources

* `TESTPROC` - The number of processors to use. **Default value: 1**
* `USE_CC` - The C compiler to use.  Options are `gcc`, `clang`, `mpi`.  **Default value: gcc**


## Examples

    $ docker run --rm -it -e TESTPROC=8 -v $(pwd)/artifacts:/artifacts unidata/netcdf-test 