#!/bin/bash
# Utility script for running continuous ctest script.

HNAME=`hostname | cut -d"." -f 1`

CMAKE_PREFIX_PATH="/machine/wfisher/local" ctest -V -S CI.cmake
