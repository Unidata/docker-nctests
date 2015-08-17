# unidata/nctests

## Overview

This docker image is used to perform spot-tests on Unidata `netCDF` packages.  It can be used to test code repositories remotely or locally.  See [Examples](#examples) for various command-line recipes for using this package.

When this docker container is run, it will check out the following packages from the Unidata github site:

* netcdf-c
* netcdf-fortran
* netcdf-cxx4

Each package will be built and tested.  This way, we can see if any changes in `netcdf-c` break anything which depends on it (`netcdf-fortran` and `netcdf-cxx4`).

## Specifying an Alternative Branch

You can specify an alternative branch for `netcdf-c` than `master` using the following syntax.

    $ docker run -e CBRANCH="branch name" unidata/nctests

## Working with local copies instead of pulling from GitHub

It is possible to use local directories instead of pulling from github. You do this by mounting your local git directory to the root of the docker image filesystem, e.g.

    $ docker run -v $(pwd)/netcdf-c:/netcdf-c unidata/nctests
    
When the image runs, it will check for the existence of `/netcdf-c`, `/netcdf-fortran` and `/netcdf-cxx4`.  If they exist, the image will clone from these instead of pulling from GitHub.

> Note: Because it is cloning from a 'local' directory, it is important that you have that local directory already on the branch you want to analyze.  You will still need to set the appropriate Environmental Variable, however, if you want the build to be properly labelled for the CDash Dashboard.
    
## Environmental Variables <A name="variables"></A>

The following environmental variables can be used to control the behavior at runtime.
* `CMD` - Run an alternative command. Options for this are `help`.
* `USEDASH` - Set to any non-`TRUE` value to disable using the remote dashboard.

---- 
 
* `CBRANCH` - Git branch for `netcdf-c`
* `FBRANCH` - Git branch for `netcdf-fortran`
* `CXXBRANCH` - Git branch for `netcdf-cxx4`

---- 
 
* `COPTS` - CMake options for `netcdf-c`
* `FOPTS` - CMake options for `netcdf-fortran`
* `CXXOPTS` - CMake options for `netcdf-cxx4`

----
 
* `RUNF` - Set to `OFF`, `FALSE`, anything but `TRUE`, to disable running fortran tests.
* `RUNCXX` - Set to `OFF`, `FALSE`, anything but `TRUE`, to disable running netcdf-cxx4 tests.

----

* `CREPS` - Default 1.  How many times to repeat the `netcdf-c` build and tests.
* `FREPS` - Default 1.  How many times to repeat the `netcdf-fortran` build and tests.
* `CXXREPS` - Default 1.  How many times to repeat the `netcdf-cxx4` build and tests.


## Examples <A name="examples"></A>

* [Show the help file](#help)
* [Run a docker container Interactively](#interactive)
* [Run all tests (standard use case)](#standard)
* [Run all tests against a particular netcdf-c branch.](#usebranch)
* [Turn off DAP tests.](#nodap)
* [Disable remote dashboard, just use local output](#noremote)
* [Test a local git repository instead of pulling from Github](#uselocal)
* [Test local git repository, disable fortran, c++ and remote dashboard](#localdebug)

### Important Information for the Examples

> For these examples, we will assume you are working on a command line, and located in the root `netcdf-c` directory, such that `$(pwd)` resolves to /location/to/root/netcdf/directory.

*The following command line options will be used repeatedly, so I will explain them here.  For a full explanation of docker command line arguments, see https://docs.docker.com/reference/commandline/cli/.*

* `--rm`: clean up the docker image after it exits.
* `-it`: Run as an interactive shell. This allows us to `ctrl-c` a running docker instance.
* `-v`: Mount a local volume to the docker image.
* `-e`: Set an environmental variable.

> The docker images/tags, `unidata/nctests:serial`, `unidata/nctests:mpich`, etc, do not matter here.  So we will simply use `unidata/nctests` (which defaults to `serial`); replace with your tag of choice, they should all work.

See [the section on environmental variables](#variables) for a complete list of variables understood by `unidata/nctests`.

### - Show the help file <A name="help"></A>
	
This will show you the help file for the docker image.

    $ docker run --rm -it -e CMD=help unidata/nctests

### - Run a docker container *interactively* <A name="interactive"></A>

This will put you into the shell for the docker container.  Note that any changes you make will not persist once you exit.  

    $ docker run --rm -it unidata/nctests bash

### - Run all tests (standard use case) <A name="standard"></A>

    $ docker run --rm -it unidata/nctests
    
### - Run all tests against a specific branch <A name="usebranch"></A>
    
    $ docker run --rm -it -e CBRANCH=working unidata/nctests
    
### - Turn off DAP tests by passing in a cmake variable <A name="nodap"></A>

    $ docker run --rm -it -e COPTS="-DENABLE_DAP=OFF" unidata/nctests

### - Run all of the tests but do not use the remote dashboard <A name="noremote"></A>

    $ docker run --rm -it -e USEDASH=OFF unidata/nctests
    
### - Run the tests against a local copy of the netcdf-c git repository instead of pulling from GitHub <A name="uselocal"></A>

Note that you will not switch branches inside the docker container when running like this; you must make sure your local repository (that you're at the root of, remember?) is on the branch you want to analyze.

    $ docker run --rm -it -v $(pwd):/netcdf-c unidata/nctests
    
### - Run the tests against a local copy, and disable the fortran, c++ and remote dashboard. <A name="localdebug"></A>

    $ docker run --rm -it -v $(pwd):/netcdf-c -e USEDASH=OFF -e RUNF=OFF -e RUNCXX=OFF unidata/nctests
    
