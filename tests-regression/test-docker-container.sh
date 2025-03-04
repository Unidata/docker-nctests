#!/bin/bash
#
# This script tests the docker container by checking out the netcdf-c and netcdf-fortran directories,
# setting the appropriate environmental variables to test a github environment/
# e.g. GITHUB_ACTIONS=TRUE, REPO_TYPE="c/fortran/cxx4/java"
#

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

###
# Begin running tests
###


DCMD="docker run --rm -it -v ${NCDIR}:/netcdf-c -v ${ENVDIR}:/environments -v ${NFDIR}:/netcdf-fortran docker.unidata.ucar.edu/nctests"
echo ""
echo -e "Running Baseline Docker Test:"
echo -e "============================="
echo -e "\to NetCDF-C, NetCDF-Fortran"
echo -e "\to command: ${DCMD}"
${DCMD} >> ${LOGFILE} 2>&1 ;

echo ""
echo -e "Running Docker Github-Emulation Tests:" 
echo -e "======================================"
##
# Run C Test
## 
DCMD="docker run --rm -it -v ${NCDIR}:/github/workspace -v ${ENVDIR}:/environments -e GITHUB_ACTIONS="TRUE" -e REPO_TYPE="c" docker.unidata.ucar.edu/nctests"
echo -e "\to NetCDF-C"
echo -e "\t\to GITHUB_ACTIONS=TRUE"
echo -e "\t\to REPO_TYPE=c"
echo -e "\t\to command: ${DCMD}"

${DCMD} >> ${LOGFILE} 2>&1 ; CHECKERR

##
# Run Fortran Test
##
DCMD="docker run --rm -it -v ${NFDIR}:/github/workspace -v ${ENVDIR}:/environments -e GITHUB_ACTIONS="TRUE" -e RUNC=OFF -e REPO_TYPE="fortran" docker.unidata.ucar.edu/nctests"
echo -e "\to NetCDF-Fortran"
echo -e "\t\to GITHUB_ACTIONS=TRUE"
echo -e "\t\to REPO_TYPE=fortran"
echo -e "\t\to command: ${DCMD}"

${DCMD} >> ${LOGFILE} 2>&1 ; CHECKERR

##
# Run Java Test
##
DCMD="docker run --rm -it -v ${NFDIR}:/github/workspace -v ${ENVDIR}:/environments -e GITHUB_ACTIONS="TRUE" -e RUNC=OFF -e RUNF=OFF -e RUNJAVA=TRUE -e REPO_TYPE="java" docker.unidata.ucar.edu/nctests"
echo -e "\to NetCDF-Java"
echo -e "\t\to GITHUB_ACTIONS=TRUE"
echo -e "\t\to REPO_TYPE=java"
echo -e "\t\to command:${DCMD}"

${DCMD} >> ${LOGFILE} 2>&1 ; CHECKERR

###
# Done Testing
###
echo -e ""
echo -e "Finished"

