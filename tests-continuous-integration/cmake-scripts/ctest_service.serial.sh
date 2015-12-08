#!/bin/bash

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM


if [ -f "/usr/sbin/crond" ]; then
    echo "Starting Crond"
    sudo crond
else
    echo "Starting Cron"
    sudo cron
fi

if [ -f /usr/bin/ps ]; then
  ps aux | grep cron
fi

# Give docker time to start all jobs before hammering the CPU.
echo "Sleeping 30 seconds before starting."
sleep 60

echo "Starting Tests"

ctest -V -S CI.cmake > ccontinuous_test.out 2>&1 &
ctest -V -S FCI.cmake > fcontinuous_test.out 2>&1 &
ctest -V -S CXX4I.cmake > cxx4continuous_test.out 2>&1 &
sleep 5
tail -f ccontinuous_test.out

#echo "[Continuous Integration Tests in Progress. Press Enter 3x to Exit]"
#read
#echo "[Continuous Integration Tests in Progress. Press Enter 2x to Exit]"
#read
#echo "[Continuous Integration Tests in Progress. Press Enter to Exit]"
#read
