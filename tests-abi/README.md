# Generate ABI Difference Reports

This docker container generates ABI difference reports for two versions of netcdf.  It uses the tools maintained by `lvc` at http://github.com/lvc.

Two versions are required, and an `/output` directory must be mapped.

## Options

* `DIST`: Specify what distribution to use.  Options are `nc` (default), `nf`, `cxx4`.

## Usage

    $ docker run -it e DIST="nc" -e OLDVER="OLDBRANCH" -e NEWVER="NEWBRANCH" -v $(pwd):/output unidata/ncabi
