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
    REPS=$4
    USECMAKE=$5
    USEAC=$6

    xterm -T "$WINTITLE [$CBRANCH]" -bg black -fg white -geometry 140x20 -e time docker run --rm -it -e CBRANCH=$CBRANCH -e CREPS=$REPS -e FREPS=$REPS -e CXXREPS=$REPS -e USECMAKE=$USECMAKE -e USEAC=$USEACC $DIMAGE &
    return 0
}

dohelp ()
{
    echo ""
    echo "Usage: $0 -[ix]"
    echo -e "\t -i     Run 32-bit tests."
    echo -e "\t -x     Run 64-bit tests."
    echo -e "\t -b     Specify a branch. Default is 'master'"
    echo -e "\t -r     Number of times to repeat the tests. Default is '1'"
    echo -e "\t -a     Enable Autoconf-based builds, disable cmake-based builds."
    echo ""
}

DO32=""
DO64=""
BRANCH="master"
MREPS=1
DOAC="OFF"
DOCMAKE="TRUE"

if [ $# -lt 1 ]; then
    dohelp
    exit 0
fi

while getopts "ixb:r:a" o; do
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
        r)
            MREPS=${OPTARG}
            ;;
        a)
            DCMAKE="FALSE"
            DOAC="TRUE"
            ;;
        *)
            dohelp
            exit 0
    esac
done

if [ "x$DO32" == "xTRUE" ]; then
    runtest serial32 unidata/nctests:serial32 $BRANCH $MREPS $DOCMAKE $DOAC
    sleep 3

    runtest openmpi32 unidata/nctests:openmpi32 $BRANCH $MREPS $DOCMAKE $DOAC
    sleep 3

    runtest mpich32 unidata/nctests:mpich32 $BRANCH $MREPS $DOCMAKE $DOAC
    sleep 3
fi

if [ "x$DO64" == "xTRUE" ]; then
    runtest serial unidata/nctests:serial $BRANCH $MREPS $DOCMAKE $DOAC
    sleep 3

    runtest openmpi unidata/nctests:openmpi $BRANCH $MREPS $DOCMAKE $DOAC
    sleep 3

    runtest mpich unidata/nctests:mpich $BRANCH $MREPS $DOCMAKE $DOAC
fi

sleep 2
xterm -T "Docker Stats" -bg black -fg white -geometry 140x20 -e docker stats $(docker ps -q) &
