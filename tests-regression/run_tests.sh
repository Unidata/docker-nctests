#!/bin/bash
#
# Depending on value of TESTTYPE, run the appropriate script.
#

dosummary() {
    echo -e "Summary:"
    echo -e "\to GITHUB_ACTIONS: ${GITHUB_ACTIONS}"
    echo -e "\to Current User (whoami): $(whoami)"
    echo -e "\to Current directory: $(pwd)"
    echo -e "===================================="
    echo -e "\to Contents of current directory:"
    echo -e ""
    ls -alh 
    echo -e "===================================="
    echo -e "\to Contents of /home/tester/"
    echo -e ""
    ls -alh /home/tester/
    echo -e "===================================="
    echo -e ""
    echo -e "\to Environmental Variables:"
    env | sort
    echo -e ""
    echo -e ""
}

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

if [ "x${TESTTYPE}" = "xserial" ]; then
    bash -le /home/tester/run_serial_tests.sh
elif [ "x${TESTTYPE}" = "xmpich" ]; then
    bash -le /home/tester/run_par_tests.sh
else
    echo "Error: Unknown TESTTYPE"
fi

