#!/bin/bash
#
# Script used to run the nightly cmake-based test.
#
#set -x
PATH=/machine/wfisher/local/bin:/usr/local/bin:/usr/bin:$PATH

ISPAR=""
PAROPT="OFF"
PROJREP=""
BUILDOPS=""
BUILDCC=`which gcc`
CMAKEOPTS=""

DOHELP () {

	echo "Usage: $0 [option]"
	echo -e ""
	echo -e "Options:"
	echo -e "\t-l [lang]         Project to run."
	echo -e "\t                     o netcdf-c"
	echo -e "\t                     o netcdf-fortran"
    echo -e "\t                     o netcdf-cxx4"
	echo -e "\t-p                Parallel Build."
	echo -e ""

}

CHECKERR() {

    RC=$?
    if [[ $RC != 0 ]]; then
	echo "Error caught: $RC"
	exit "$RC"
    fi
}

####
# Parse options, validate
# arguments.
####

while getopts "l:p" o; do
    case "${o}" in
        l)
            LINTYPE=${OPTARG}
            ;;
        p)
            ISPAR="TRUE"
            PAROPT="ON"
            BUILDCC=`which mpicc`
            ;;
        *)
            dohelp
            exit 0
    esac
done

case "${LINTYPE}" in
	"netcdf-c")
		PROJREP="git://github.com/Unidata/netcdf-c"
		CMAKEOPTS="-DENABLE_PARALLEL=$PAROPT -DENABLE_PARALLEL_TESTS=$PAROPT -DENABLE_PNETCDF=$PAROPT -DCMAKE_C_COMPILER=$BUILDCC -DENABLE_EXTRA_TESTS=ON -DENABLE_HDF4=ON -DENABLE_MMAP=ON"
		;;
	"netcdf-fortran")
		PROJREP="git://github.com/Unidata/netcdf-fortran"
		CMAKEOPTS="-DCMAKE_PREFIX_PATH=$HOME/local2 -DCMAKE_C_COMPILER=$BUILDCC"

        if [ "x$ISPAR" = "xTRUE" ]; then
            CMAKEOPTS="$CMAKEOPTS -DCMAKE_Fortran_COMPILER=`which mpif90` -DTEST_PARALLEL=ON"
        fi
		;;
    "netcdf-cxx4")
        PROJREP="git://github.com/Unidata/netcdf-cxx4"
        CMAKEOPTS="-DCMAKE_PREFIX_PATH=$HOME/local2 -DCMAKE_C_COMPILER=$BUILDCC"
        ;;
	*)
		DOHELP
		exit 1
		;;
esac


WORKINGDIR="netcdf-nightly-"`date +%s`
BUILDDIR="build"
LOGFILE=$WORKINGDIR.log
CMAKECMD=`which cmake`

echo "Using CMake Program: $CMAKECMD"
echo "Compiler: $BUILDCC"


git clone $PROJREP $WORKINGDIR
cd $WORKINGDIR
CHECKERR
mkdir $BUILDDIR
CHECKERR
cd $BUILDDIR
CHECKERR


# Run cmake to configure
$CMAKECMD .. $CMAKEOPTS
CHECKERR

$CMAKECMD --build . --target Nightly
CHECKERR

echo "Finished"
exit 0

## Stuff for real machines on the network.
HNAME=`hostname | cut -d"." -f 1`

PREF=""

case "$HNAME" in
    'spike')
	PREF="-DCMAKE_PREFIX_PATH=/machine/wfisher/local"
	;;
    'spock')
	PREF="-DCMAKE_PREFIX_PATH=/machine/wfisher/local"
	;;
    'sol')
	PREF="-DCMAKE_PREFIX_PATH=/machine/wfisher/local -DCMAKE_C_COMPILER=`which gcc`"
	;;
    'yakov')
	;;
    'claw')
	;;
    *)
	;;
esac
#export PREF



echo "Finished"
