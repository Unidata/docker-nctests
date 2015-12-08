#!/bin/bash
# Script to do a coverity build on code, create the project.tgz file,
# and copy the file to the host OS
DOSUBMIT=""
DOBUILD=""
DOCLEAN=""
DOPACK=""
DOCO=""
DOHDF4=""
DOCMAKE=""
NCVERSION='netcdf-master'
if [ $# -gt 0 ]; then
	while getopts "dbchsfm" Option; do
	    case $Option in
		b ) DOBUILD="TRUE";;
		c ) DOCLEAN="TRUE";;
		d ) DOCO="TRUE";;
		s ) DOSUBMIT="TRUE";DOPACK="TRUE";;
		f ) DOHDF4="TRUE";;
		m ) DOCMAKE="TRUE";;
		* ) echo; echo -e "Usage: $0 [-hdbcs]";echo -e "-h:\tShow this help dialog.\n-d\tCheck out fresh netcdf code.\n-b:\tExecute cov-build command, otherwise assumes this has been done.\n-s:\tSubmit project.tgz to Coverity for analysis (requires curl)\n-f:\tEnable HDF4 Compilation, Tests.\n-c:\tRun 'make distclean' before building.\n-m:\tUse CMake instead of autotools.\n";echo "";echo ""; exit;
	    esac
	 done
else
    $0 -h
    exit
fi

TFILE="project.tgz"
TDIR="covtmp"
COVDIR="cov-int"
RFILE="README"

COPROJECT="NetCDF"
COFILE="netcdf-cov-"`date +%s`
COPASSWD="cQx2rcuw"
COUSER="wfisher@unidata.ucar.edu"
COSITE="https://scan.coverity.com/builds"

if [ x$DOCO = "xTRUE" ]; then
    #svn co https://sub.unidata.ucar.edu/netcdf/trunk $COFILE
    git clone http://github.com/Unidata/netcdf-c $COFILE
    if [ $? != "0" ]; then
        echo "Error $? checking out latest netcdf code."
        exit 2
    fi
    cd $COFILE

fi

if [ x$DOCLEAN = "xTRUE" ]; then
    make distclean
fi

if [ x$DOBUILD = "xTRUE" ]; then

    if [ x$DOCMAKE = "xTRUE" ]; then
	ARGS="-DENABLE_TESTS=OFF"
	mkdir build
	cd build
	cov-build --dir ../$COVDIR cmake .. -DENABLE_TESTS=OFF
	if [ $? != "0" ]; then
	    echo "Error running cmake."
	    exit 2
	fi

	cov-build --dir ../$COVDIR make
	if [ $? != "0" ]; then
	    echo "Error compiling."
	    exit 2
	fi
        cd ..
    else
	autoreconf -i -f
	ARGS=""
	if [ x$DOHDF4 = "xTRUE" ]; then
	    ARGS='--enable-hdf4 --enable-hdf4-file-tests'
	fi

	./configure $ARGS
	cov-build --dir $COVDIR make
	if [ $? != "0" ]; then
            echo "Error $? compiling netcdf code."
            exit 2
	fi
    fi
fi

if [ x$DOPACK = "xTRUE" ]; then

    tar czvf $TFILE $COVDIR
fi

if [ x$DOSUBMIT = "xTRUE" ]; then

    if [ ! -e $TFILE ]; then
	echo "Error, file $TFILE does not exist. Aborting."
	exit 2
    fi

    CURLFILE=`pwd`/$TFILE
    set -x
    curl --form file=@$CURLFILE --form project=$COPROJECT --form token=$COPASSWD --form email=$COUSER $COSITE --form version=$NCVERSION
fi
