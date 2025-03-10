#!/bin/bash
#
# Depending on value of TESTTYPE, run the appropriate script.
#

function ERR {
    RES=$?
    if [ $RES -ne 0 ]; then
        git stash
        git clean -fd
        git reset --hard
        echo "$(git status | head -n 1): Error found: $RES"
        echo -e "\t[x] $(git status | head -n 1): Error found: $RES" >> "${LOGFILE}"
        exit $RES
    fi

}

if [ "${USER}" = "root" ]; then
    export SUDOCMD=""
else
    export SUDOCMD="sudo"
fi

dosummary() {
    echo -e "===================================="
    echo -e "\to Current Environmental Variables:"
    echo -e ""
    env | sort
    echo -e ""
    echo -e ""
    echo -e "===================================="
    echo -e "Summary:"
    echo -e "\to GITHUB_ACTIONS: ${GITHUB_ACTIONS}"
    echo -e "\to Current User (whoami): $(whoami)"
    echo -e "\to Current directory: $(pwd)"
    echo -e "\to Working Directory: ${WORKING_DIRECTORY}"
    echo -e "===================================="
    echo -e "\to Contents of current directory:"
    echo -e ""
    ls -alh 
    echo -e "===================================="
    echo -e "\to Contents of /home/tester/"
    echo -e ""
    ls -alh /home/tester/
    echo -e "===================================="
    echo -e "\to Contents of ${WORKING_DIRECTORY}"
    echo -e ""
    ls -alh ${WORKING_DIRECTOR}
    echo -e "===================================="
}

if [ "${GITHUB_ACTIONS}" = "true" -o "${GITHUB_ACTIONS}" = "TRUE" ]; then

    if [ "${REPO_TYPE}" = "c" ]; then
        export C_VOLUME_MAP="/github/workspace"
        ${SUDOCMD} mkdir -p /netcdf-c
        ${SUDOCMD} cp -R /github/workspace/. /netcdf-c
        ${SUDOCMD} chown -R tester:tester /netcdf-c
    fi
    if [ "${REPO_TYPE}" = "fortran" ]; then
        export FORTRAN_VOLUME_MAP="/github/workspace"
        ${SUDOCMD} mkdir -p /netcdf-fortran
        ${SUDOCMD} cp -R /github/workspace/. /netcdf-fortran
        ${SUDOCMD} chown -R tester:tester /netcdf-fortran
    fi
    if [ "${REPO_TYPE}" = "cxx4" ]; then
        export CXX4_VOLUME_MAP="/github/workspace"
        ${SUDOCMD} mkdir -p /netcdf-cxx4
        ${SUDOCMD} cp -R /github/workspace/. /netcdf-cxx4
        ${SUDOCMD} chown -R tester:tester /netcdf-cxx4
    fi
    if [ "${REPO_TYPE}" = "java" ]; then
        export JAVA_VOLUME_MAP="/github/workspace"
        ${SUDOCMD} mkdir -p /netcdf-java
        ${SUDOCMD} cp -R /github/workspace/. /netcdf-java
        ${SUDOCMD} chown -R tester:tester /netcdf-java
    fi    

fi

if [ "${TESTPROC}" = "" ]; then
    export TESTPROC=$(nproc)
fi

dosummary



if [ "x${USE_CC}" = "xmpicc" ]; then
    TESTTYPE="mpich"
elif [ "x${USE_CC}" = "xgcc" -o "x${USE_CC}" = "xclang" ]; then
    TESTTYPE="serial"
else
    echo "Unknown compiler requested:  ${USE_CC}"
    exit 1
fi

echo $(date)
echo "Running Test Type: ${TESTTYPE}"
echo "Using compiler: ${USE_CC}"
echo ""
sleep 1

cd /home/tester
export WORKING_DIRECTORY=${WORKING_DIRECTORY}/build-$(date +%s)

${SUDOCMD} mkdir -p ${WORKING_DIRECTORY}
${SUDOCMD} chown -R tester:tester ${WORKING_DIRECTORY}
cd ${WORKING_DIRECTORY}

bash -le /home/tester/run_netcdf_tests.sh ; ERR
