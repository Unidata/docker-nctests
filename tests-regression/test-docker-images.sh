#!/bin/bash
#
# This script tests the docker container by checking out the netcdf-c, netcdf-fortran, and
# netcdf-java directories.
#

set -e

CHECKERR() {

    RES=$?

    if [[ $RES -ne 0 ]]; then
        echo "Error Caught: $RES"
        exit $RES
    fi

}

dosummary() {
    echo -e ""
    echo -e "Running docker tests in directory ./${TESTLOC}"
    echo -e "\to TESTDIR: ${TESTDIR}"
    echo -e "\to Logfile: ${LOGFILE}"
    echo -e "\to NCVER: ${NCVER}"
    echo -e "\t\to NCDIR: ${NCDIR}"
    echo -e "\to NFVER: ${NFVER}"
    echo -e "\t\to NFDIR: ${NFDIR}"
    echo -e "\to NJVER: ${NJVER}"
    echo -e "\t\to NJDIR: ${NJDIR}"
    echo -e ""
    echo -e "Press [Return] to continue"
    read
}

NCVER="v4.9.2"
NFVER="v4.6.1"
NJVER="maint-5.x"

TESTSUFFIX=$(date +%s | cut -c 6- )
TESTLOC=testdir-${TESTSUFFIX}
TESTDIR=$(pwd)/${TESTLOC}
mkdir -p ${TESTDIR}
cd ${TESTDIR}

NCDIR="$(pwd)/netcdf-c-${TESTSUFFIX}"
NFDIR="$(pwd)/netcdf-f-${TESTSUFFIX}"
NJDIR="$(pwd)/netcdf-java-${TESTSUFFIX}"
ENVDIR=$(pwd)/environments-${TESTSUFFIX}

LOGFILE="$(pwd)/test-${TESTSUFFIX}-log.txt"


touch ${LOGFILE}
if command -v xterm &> /dev/null; then
    xterm -bg black -fg white -geometry 200x30+10+10 -e "tail -f ${LOGFILE}" &
fi
dosummary

echo -e "Checking out Repositories:"
echo -e "\to NetCDF-C"
git clone git@github.com:Unidata/netcdf-c --single-branch --branch ${NCVER} ${NCDIR}  >> ${LOGFILE} 2>&1 ; CHECKERR
echo -e "\to NetCDF-Fortran"
git clone git@github.com:Unidata/netcdf-fortran --single-branch --branch ${NFVER} ${NFDIR}  >> ${LOGFILE} 2>&1 ; CHECKERR
echo -e "\to NetCDF-Java"
git clone git@github.com:Unidata/netcdf-java --single-branch --branch ${NJVER} ${NJDIR}  >> ${LOGFILE} 2>&1 ; CHECKERR

###
# Begin running tests
###

DCMD="docker run --rm -it -v ${NCDIR}:/netcdf-c -v ${NFDIR}:/netcdf-fortran -v ${NJVER}:/netcdf-java -v ${ENVDIR}:/environments -e USE_CC=gcc docker.unidata.ucar.edu/nctests"
echo ""
echo -e "Running Baseline Docker Test (gcc):"
echo -e "======================================"
echo -e "\to NetCDF-C: ${NCVER}"
echo -e "\to NetCDF-Fortran: ${NFVER}"
echo -e "\to NetCDF-Java: ${NJVER}"
echo -e "\to command: ${DCMD}"
${DCMD} >> ${LOGFILE} 2>&1 ; CHECKERR
echo ""

DCMD="docker run --rm -it -v ${NCDIR}:/netcdf-c -v ${NFDIR}:/netcdf-fortran -v ${NJVER}:/netcdf-java -v ${ENVDIR}:/environments -e USE_CC=clang docker.unidata.ucar.edu/nctests"
echo ""
echo -e "Running Baseline Docker Test (clang):"
echo -e "======================================"
echo -e "\to NetCDF-C: ${NCVER}"
echo -e "\to NetCDF-Fortran: ${NFVER}"
echo -e "\to NetCDF-Java: ${NJVER}"
echo -e "\to command: ${DCMD}"
${DCMD} >> ${LOGFILE} 2>&1 ; CHECKERR
echo ""

DCMD="docker run --rm -it -v ${NCDIR}:/netcdf-c -v ${NFDIR}:/netcdf-fortran -v ${NJVER}:/netcdf-java -v ${ENVDIR}:/environments -e USE_CC=clang docker.unidata.ucar.edu/nctests"
echo ""
echo -e "Running Baseline Docker Test (mpicc) (default version):"
echo -e "======================================"
echo -e "\to NetCDF-C: ${NCVER}"
echo -e "\to NetCDF-Fortran: ${NFVER}"
echo -e "\to NetCDF-Java: ${NJVER}"
echo -e "\to command: ${DCMD}"
${DCMD} >> ${LOGFILE} 2>&1 ; CHECKERR
echo ""

MPIVER="4.3.0"
DCMD="docker run --rm -it -v ${NCDIR}:/netcdf-c -v ${NFDIR}:/netcdf-fortran -v ${NJVER}:/netcdf-java -v ${ENVDIR}:/environments -e MPICHVER=${MPIVER} -e USE_CC=clang docker.unidata.ucar.edu/nctests"
echo ""
echo -e "Running Baseline Docker Test (mpicc) (version ${MPIVER}):"
echo -e "======================================"
echo -e "\to NetCDF-C: ${NCVER}"
echo -e "\to NetCDF-Fortran: ${NFVER}"
echo -e "\to NetCDF-Java: ${NJVER}"
echo -e "\to command: ${DCMD}"
${DCMD} >> ${LOGFILE} 2>&1 ; CHECKERR
echo ""

###
# Done Testing
###
echo -e ""
echo -e "Finished"
echo -e ""
