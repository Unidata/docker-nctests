#!/bin/bash

###
# Xenial
###
xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Xenial: 64-bit]" -e "docker build -t unidata/ncci:xenial-x64 -f Dockerfile.xenial-x64 . ; echo "" && echo '[Press Return to Close]' && read " &
sleep 1

xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Xenial: 32-bit]" -e "docker build -t unidata/ncci:xenial-x86 -f Dockerfile.xenial-x86 . ; echo "" &&  echo '[Press Return to Close]' && read " &
sleep 1

###
# Trusty
###
xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Trusty: 64-bit]" -e "docker build -t unidata/ncci:trusty-x64 -f Dockerfile.trusty-x64 . ; echo "" && echo '[Press Return to Close]' && read " &
sleep 1

xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Trusty: 32-bit]" -e "docker build -t unidata/ncci:trusty-x86 -f Dockerfile.trusty-x86 . ; echo "" && echo '[Press Return to Close]' && read " &
sleep 1

###
# Trusty - Parallel
###
xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Xenial OpenMPI: 64-bit]" -e "docker build -t unidata/ncci:xenial-openmpi-x64 -f Dockerfile.xenial-openmpi-x64 . ; echo "" && echo '[Press Return to Close]' && read " &

xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Xenial MPICH: 64-bit]" -e "docker build -t unidata/ncci:xenial-mpich-x64 -f Dockerfile.xenial-mpich-x64 . ; echo "" && echo '[Press Return to Close]' && read " &

sleep 1

###
# Fedora
###
xterm -geometry 150x20 -bg black -fg white -T "[Fedora 21: 64-bit]" -e "docker build -t unidata/ncci:fedora21-x64 -f Dockerfile.fedora21-x64 . ; echo "" &&  echo '[Press Return to Close]' && read " &
sleep 1

xterm -geometry 150x20 -bg black -fg white -T "[Fedora 22: 64-bit]" -e "docker build -t unidata/ncci:fedora22-x64 -f Dockerfile.fedora22-x64 . ; echo "" &&  echo '[Press Return to Close]' && read " &
sleep 1

xterm -geometry 150x20 -bg black -fg white -T "[Fedora 23: 64-bit]" -e "docker build -t unidata/ncci:fedora23-x64 -f Dockerfile.fedora23-x64 . ; echo "" &&  echo '[Press Return to Close]' && read " &
sleep 1

###
# Centos
###
xterm -geometry 150x20 -bg black -fg white -T "[Centos 7: 64-bit]" -e "docker build -t unidata/ncci:centos7-x64 -f Dockerfile.centos7-x64 . ; echo "" && echo '[Press Return to Close]' && read " &
sleep 1

echo "[Finished]"
