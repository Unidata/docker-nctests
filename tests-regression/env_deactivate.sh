#!/bin/bash
# Deactivate an existing environment
if [ "${DEV_ENV}" = "" ]; then
    echo "No active environments. Use env_activate.sh to activate one."
else
    echo "Deactivating ${DEV_ENV}"
    set -x
    export DEV_ENV=""
    export APP_ENV=""
    export CPPFLAGS="${DEV_CPPFLAGS}"
    export CPLUS_INCLUDE_PATH="${DEV_CPLUS_INCLUDE_PATH}"
    export CFLAGS="${DEV_CFLAGS}"
    export LDFLAGS="${DEV_LDFLAGS}"
    export LD_LIBRARY_PATH="${DEV_LD_LIBRARY_PATH}"
    export LIBRARY_PATH="${DEV_LIBRARY_PATH}"
    export DYLD_LIBRARY_PATH="${DEV_DYLD_LIBRARY_PATH}"
    export PATH="${DEV_PATH}"
    export CMAKE_PREFIX_PATH="${DEV_CMAKE_PREFIX_PATH}"
    export PKG_CONFIG_PATH="${DEV_PKG_CONFIG_PATH}"
    export active_dir=""
    export active_incdir=""
    export active_libdir=""
    unalias active
    unalias active_full
    unalias active_env
    unalias active_dir
    unalias active_path
    unalias active_lib
    unalias active_include
    unalias old_path
    set +x
    echo "Finished"
fi
