#!/bin/bash

set -e

###
# Define some variables
###

DOX="FALSE"

###
# Help Function
###

DOHELP()
{
    echo "Usage: $0 [options]"
    echo -e "\t-h\t This documentation."
    echo -e "\t-x\t Launch each individually in an xterm."
    echo -e "\t  \t   o Default: Launch in background."
    echo ""
}
###
#
# Utility Function
#
# Input:
#  * Docker image name
#  * Tag for host name
#  * USE-X
#
# Example: RUN_IMG unidata/ncci:vivid-x86 vivid-x86 TRUE
#
###
RUN_IMG()
{
    IMG=$1
    TAG=$2
    USEX=$3

    if [ "x$USEX" == "xTRUE" ]; then
        xterm -bg black -fg white -T "[$IMG]" -geometry 100x10 -e "docker run --rm -it -h $TAG-$RSHORT $IMG"&
    else
        docker run --name "${TAG}" -d -it -h "${TAG}-${RSHORT}" "${IMG}"
    fi
}


###
# Parse command-line options.
###
while getopts "hx" o; do
    case "${o}" in
        x)
            DOX="TRUE"
            ;;
        *)
            DOHELP
            exit 0
    esac
done

# Generate a unique identifier string.

RSTRING="$(openssl rand -hex 3)"
RSHORT="$(echo ${RSTRING} | head -c 4)"
echo "Generating unique identifier: ${RSTRING}"
echo "Using unique hostname suffix: ${RSHORT}"
echo "Launching in xterm sessions:  ${DOX}"
echo ""


###
# Xenial
###

RUN_IMG "unidata/ncci:xenial-x64" "xenial-x64" "${DOX}" ; sleep 1
RUN_IMG "unidata/ncci:xenial-x86" "xenial-x86" "${DOX}" ; sleep 1

###
# Xenial - Parallel
###

RUN_IMG "unidata/ncci:xenial-openmpi-x64" "xenial-openmpi-x64" "${DOX}" ; sleep 1
RUN_IMG "unidata/ncci:xenial-mpich-x64" "xenial-mpich-x64" "${DOX}" ; sleep 1

###
# Fedora
###

RUN_IMG "unidata/ncci:fedora27-x64" "fedora27-x64" "${DOX}" ; sleep 1
RUN_IMG "unidata/ncci:fedora26-x64" "fedora26-x64" "${DOX}" ; sleep 1

###
# Centos
###

RUN_IMG "unidata/ncci:centos7-x64" "centos7-x64" "${DOX}" ; sleep 1

echo "Finished"
echo ""
