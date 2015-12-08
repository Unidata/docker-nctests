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
# Wily
###

RUN_IMG "unidata/ncci:wily-x64" "wily-x64" "${DOX}" ; sleep 1
RUN_IMG "unidata/ncci:wily-x86" "wily-x86" "${DOX}" ; sleep 1

###
# Trusty
###

RUN_IMG "unidata/ncci:trusty-x64" "trusty-x64" "${DOX}" ; sleep 1
RUN_IMG "unidata/ncci:trusty-x86" "trusty-x86" "${DOX}" ; sleep 1

###
# Trusty - Parallel
###

RUN_IMG "unidata/ncci:trusty-openmpi-x64" "trusty-openmpi-x64" "${DOX}" ; sleep 1
RUN_IMG "unidata/ncci:trusty-mpich-x64" "trusty-mpich-x64" "${DOX}" ; sleep 1

###
# Fedora
###

RUN_IMG "unidata/ncci:fedora23-x64" "fedora23-x64" "${DOX}" ; sleep 1
RUN_IMG "unidata/ncci:fedora22-x64" "fedora22-x64" "${DOX}" ; sleep 1
RUN_IMG "unidata/ncci:fedora21-x64" "fedora21-x64" "${DOX}" ; sleep 1

###
# Centos
###

RUN_IMG "unidata/ncci:centos7-x64" "centos7-x64" "${DOX}" ; sleep 1

echo "Finished"
echo ""
