#!/bin/bash

###
# Xenial
###
xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Xenial: 64-bit]" -e "docker build -t unidata/ncci:xenial-x64 -f Dockerfile.xenial-x64 . ; echo "" && echo '[Press Return to Close]' && read " &
sleep 1

xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Xenial: 32-bit]" -e "docker build -t unidata/ncci:xenial-x86 -f Dockerfile.xenial-x86 . ; echo "" &&  echo '[Press Return to Close]' && read " &
sleep 1

###
# Xenial - Parallel
###

xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Xenial: OpenMPI]" -e "docker build -t unidata/ncci:xenial-openmpi-x64 -f Dockerfile.xenial-openmpi-x64 . ; echo "" &&  echo '[Press Return to Close]' && read " &
sleep 1

xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Xenial: MPICH]" -e "docker build -t unidata/ncci:xenial-mpich-x64 -f Dockerfile.xenial-mpich-x64 . ; echo "" &&  echo '[Press Return to Close]' && read " &
sleep 1



###
# Fedora
###
xterm -geometry 150x20 -bg black -fg white -T "[Fedora 26: 64-bit]" -e "docker build -t unidata/ncci:fedora26-x64 -f Dockerfile.fedora26-x64 . ; echo "" &&  echo '[Press Return to Close]' && read " &
sleep 1

xterm -geometry 150x20 -bg black -fg white -T "[Fedora 27: 64-bit]" -e "docker build -t unidata/ncci:fedora27-x64 -f Dockerfile.fedora27-x64 . ; echo "" &&  echo '[Press Return to Close]' && read " &
sleep 1

###
# Centos
###
xterm -geometry 150x20 -bg black -fg white -T "[Centos 7: 64-bit]" -e "docker build -t unidata/ncci:centos7-x64 -f Dockerfile.centos7-x64 . ; echo "" && echo '[Press Return to Close]' && read " &
sleep 1

echo "[Finished]"
