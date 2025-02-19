#!/bin/bash
#
# Depending on value of TESTTYPE, run the appropriate script.
#

echo $(date)
echo "Running Test Type: ${TESTTYPE}"
echo ""
sleep 1

if [ "x${TESTTYPE}" = "xserial" ]; then
    bash -le /home/tester/run_serial_tests.sh
elif [ "x${TESTTYPE}" = "xmpich" ]; then
    bash -le /home/tester/run_par_tests.sh
else
    echo "Error: Unknown TESTTYPE"
fi

