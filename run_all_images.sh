#!/bin/bash
###
# Utility script which will spawn all docker images
# in unidata/nctests.
###

##
# runtest() arguments:
# 1. xterm window title.
# 2. docker image to run.
# 3. netcdf-c branch to run.
##

runtest() {

    WINTITLE=$1
    DIMAGE=$2
    CBRANCH=$3

    xterm -T "$WINTITLE [$CBRANCH]" -bg black -fg white -geometry 140x20+10+10 -e time docker run --rm -it -e CBRANCH=$CBRANCH $DIMAGE &
    return 0
}

dohelp ()
{
    echo ""
    echo "Usage: $0 -[ix]"
    echo -e "\t -i     Run 32-bit tests."
    echo -e "\t -x     Run 64-bit tests."
    echo -e "\t -b     Specify a branch. Default is 'master'"
    echo ""
}

DO32=""
DO64=""
BRANCH="master"

if [ $# -lt 1 ]; then
    dohelp
    exit 0
fi

while getopts "ixb:" o; do
    case "${o}" in
        i)
            DO32="TRUE"
            ;;
        x)
            DO64="TRUE"
            ;;
        b)
            BRANCH=${OPTARG}
            if [ "x$BRANCH" == "x" ]; then
                dohelp
                exit 0
            fi
            ;;
        *)
            dohelp
            exit 0
    esac
done

if [ "x$DO32" == "xTRUE" ]; then
    runtest serial32 unidata/nctests:serial32 $BRANCH
    sleep 3

    runtest openmpi32 unidata/nctests:openmpi32 $BRANCH
    sleep 3

    runtest mpich32 unidata/nctests:mpich32 $BRANCH
    sleep 3
fi

if [ "x$DO64" == "xTRUE" ]; then
    runtest serial unidata/nctests:serial $BRANCH
    sleep 3

    runtest openmpi unidata/nctests:openmpi $BRANCH
    sleep 3

    runtest mpich unidata/nctests:mpich $BRANCH
fi

sleep 5
xterm -T "Docker Stats" -bg black -fg white -geometry 140x20+10+10 -e docker stats $(docker ps -q) &
