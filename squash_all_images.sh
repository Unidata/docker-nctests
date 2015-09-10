#!/bin/bash
#
# Depends on docker-squash utility found at:
# - https://github.com/jwilder/docker-squash
#
# Note that there is a markdown file with OSX-specific
# instructions.

set -e

PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"

IMGS="unidata/nctests:base unidata/nctests:base32 unidata/nctests:serial unidata/nctests:serial32 unidata/nctests:mpich unidata/nctests:mpich32 unidata/nctests:openmpi unidata/nctests:openmpi32"

for X in $IMGS; do
    echo $X
    set -x
    docker save $X | sudo TMPDIR=/sandbox/tmp docker-squash -verbose -t $X | docker load
    set +x
done
