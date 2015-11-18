# unidata/nctests

The Dockerfile and other information for this image may be found either by running the image interactively, or by going to the corresponding github repository: http://github.com/Unidata/docker-nctests

## Overview

This docker image is used to perform spot-tests on Unidata `netCDF` packages.  It can be used to test code repositories remotely or locally.  See [Examples](#examples) for various command-line recipes for using this package.

When this docker container is run, it will check out the following packages from the Unidata github site:

* netcdf-c
* netcdf-fortran
* netcdf-cxx4
* netcdf4-python
* NetCDF Operators (NCO)


Each package will be built and tested.  This way, we can see if any changes in `netcdf-c` break anything which depends on it (`netcdf-fortran` and `netcdf-cxx4`).

### NetCDF Operators (NCO)

From the [NCO website]:

> The NCO toolkit manipulates and analyzes data stored in netCDF-accessible formats, including DAP, HDF4, and HDF5. It exploits the geophysical expressivity of many CF (Climate & Forecast) metadata conventions, the flexible description of physical dimensions translated by UDUnits, the network transparency of OPeNDAP, the storage features (e.g., compression, chunking, groups) of HDF (the Hierarchical Data Format), and many powerful mathematical and statistical algorithms of GSL (the GNU Scientific Library). NCO is fast, powerful, and free. 

[NCO website]:http://nco.sourceforge.net/

NCO integration adds additional regression testing.

## Specifying an Alternative netcdf-c Branch



You can specify an alternative branch for `netcdf-c` than `master` using the following syntax.

    $ docker run -e CBRANCH="branch name" unidata/nctests:serial



## Working with local copies instead of pulling from GitHub

It is possible to use local directories instead of pulling from github. You do this by mounting your local git directory to the root of the docker image filesystem, e.g.

    $ docker run -v $(pwd)/netcdf-c:/netcdf-c unidata/nctests:serial
    
When the image runs, it will check for the existence of `/netcdf-c`, `/netcdf-fortran`, `/netcdf-cxx4` and `/netcdf4-python`.  If they exist, the image will clone from these instead of pulling from GitHub.

> Note: Because it is cloning from a 'local' directory, it is important that you have that local directory already on the branch you want to analyze.  You will still need to set the appropriate Environmental Variable, however, if you want the build to be properly labelled for the CDash Dashboard.
    
## Environmental Variables 

The following environmental variables can be used to control the behavior at runtime.
* `CMD` - Run an alternative command. Options for this are `help`.
* `USEDASH` - Set to any non-`TRUE` value to disable using the remote dashboard.

---- 
* `CBRANCH` - Git branch for `netcdf-c`
* `FBRANCH` - Git branch for `netcdf-fortran`
* `CXXBRANCH` - Git branch for `netcdf-cxx4`
* `PBRANCH` - Git branch for `netcdf4-python`
* `NCOBRANCH` - Git branch for `NCO`. Default: `4.5.3`.

---- 
* `COPTS` - CMake options for `netcdf-c`
* `FOPTS` - CMake options for `netcdf-fortran`
* `CXXOPTS` - CMake options for `netcdf-cxx4`

----
* `AC_COPTS` - Autoconf options for `netcdf-c`
* `AC_FOPTS` - Autoconf options for `netcdf-fortran`
* `AC_CXXOPTS` - Autoconf options for `netcdf-cxx4`

----
* `RUNF` - Set to `OFF`, `FALSE`, anything but `TRUE`, to disable running `netcdf-fortran` tests.
* `RUNCXX` - Set to `OFF`, `FALSE`, anything but `TRUE`, to disable running `netcdf-cxx4` tests.
* `RUNP` - Set to `OFF`, `FALSE`, anything but `TRUE`, to disable running `netcdf4-python` tests.
* `RUNNCO` - Set to `OFF`, `FALSE`, anything but `TRUE`, to disable running `NCO` tests.

----
* `CREPS` - Default 1.  How many times to repeat the `netcdf-c` build and tests.
* `FREPS` - Default 1.  How many times to repeat the `netcdf-fortran` build and tests.
* `CXXREPS` - Default 1.  How many times to repeat the `netcdf-cxx4` build and tests.
* `PREPS` - Default 1.  How many times to repeat the `netcdf4-python` build and tests.
* `NCOREPS` - Default 1.  How many times to repeat the `NCO` build and tests.


----
* `USECMAKE` - Default to `TRUE`. When `TRUE`, run `cmake` builds.
* `USEAC` - Default to `FALSE`. When `TRUE`, run *in-source* `autoconf`-based builds.

> Note that `USECMAKE` and `USEAC` may be used concurrently and, when coupled with `CREPS` and other loop control options, we can see if the different build systems interfere with each other.

## Examples

### Important Information for the Examples

> For these examples, we will assume you are working on a command line, and located in the root `netcdf-c` directory, such that `$(pwd)` resolves to /location/to/root/netcdf/directory.

*The following command line options will be used repeatedly, so I will explain them here.  For a full explanation of docker command line arguments, see https://docs.docker.com/reference/commandline/cli/.*

* `--rm`: clean up the docker image after it exits.
* `-it`: Run as an interactive shell. This allows us to `ctrl-c` a running docker instance.
* `-v`: Mount a local volume to the docker image.
* `-e`: Set an environmental variable.



See [the section on environmental variables](#variables) for a complete list of variables understood by `unidata/nctests`.

### - Show the help file
	
This will show you the help file for the docker image.

    $ docker run --rm -it -e CMD=help unidata/nctests:serial

### - Run a docker container *interactively*

This will put you into the shell for the docker container.  Note that any changes you make will not persist once you exit.  

    $ docker run --rm -it unidata/nctests:serial bash

### - Run all tests (standard use case)

    $ docker run --rm -it unidata/nctests:serial
    
### - Run all tests against a specific branch
    
    $ docker run --rm -it -e CBRANCH=working unidata/nctests:serial
    
### - Turn off DAP tests by passing in a cmake variable 

    $ docker run --rm -it -e COPTS="-DENABLE_DAP=OFF" unidata/nctests:serial

### - Run all of the tests but do not use the remote dashboard 

    $ docker run --rm -it -e USEDASH=OFF unidata/nctests:serial
    
### - Run the tests against a local copy of the netcdf-c git repository instead of pulling from GitHub 

> Note that you will not switch branches inside the docker container when running like this; you must make sure your local repository (that you're at the root of, remember?) is on the branch you want to analyze.

    $ docker run --rm -it -v $(pwd):/netcdf-c unidata/nctests:serial
    
### - Run the tests against a local copy, and disable the fortran, c++ and remote dashboard. 
    $ docker run --rm -it -v $(pwd):/netcdf-c -e USEDASH=OFF -e RUNF=OFF -e RUNCXX=OFF unidata/nctests:serial
    
### - Run the NetCDF-C tests using Autootools instead of CMake, and repeat the build twice. 
    # docker run --rm -it -e USECMAKE=OFF -e USEAC=TRUE -e CREPS=2 unidata/nctests:serial
    
#### Running non-serial tests

> To run any of the above examples against a different environment, you would replace `nctests:serial` with one of `nctests:openmpi`, `nctests:mpich`, `nctests:serial32`, etc.