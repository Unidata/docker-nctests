#!/bin/bash
#
# Depending on value of TESTTYPE, run the appropriate script.
#

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
    fi
    if [ "${REPO_TYPE}" = "fortran" ]; then
        export FORTRAN_VOLUME_MAP="/github/workspace"
    fi
    if [ "${REPO_TYPE}" = "cxx4" ]; then
        export CXX4_VOLUME_MAP="/github/workspace"
    fi
    if [ "${REPO_TYPE}" = "java" ]; then
        export JAVA_VOLUME_MAP="/github/workspace"
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

sudo mkdir -p ${WORKING_DIRECTORY}
sudo chown -R tester:tester ${WORKING_DIRECTORY}
cd ${WORKING_DIRECTORY}


if [ "x${TESTTYPE}" = "xserial" ]; then
    bash -le /home/tester/run_serial_tests.sh
elif [ "x${TESTTYPE}" = "xmpich" ]; then
    bash -le /home/tester/run_par_tests.sh
else
    echo "Error: Unknown TESTTYPE"
fi