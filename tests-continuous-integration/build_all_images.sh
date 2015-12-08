#!/bin/bash

###
# Wily
###
xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Wily: 64-bit]" -e "docker build -t unidata/ncci:wily-x64 -f Dockerfile.wily-x64 . ; echo "" && echo '[Press Return to Close]' && read " &
sleep 1

xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Wily: 32-bit]" -e "docker build -t unidata/ncci:wily-x86 -f Dockerfile.wily-x86 . ; echo "" &&  echo '[Press Return to Close]' && read " &
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
xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Trusty OpenMPI: 64-bit]" -e "docker build -t unidata/ncci:trusty-openmpi-x64 -f Dockerfile.trusty-openmpi-x64 . ; echo "" && echo '[Press Return to Close]' && read " &

xterm -geometry 150x20 -bg black -fg white -T "[Ubuntu Trusty MPICH: 64-bit]" -e "docker build -t unidata/ncci:trusty-mpich-x64 -f Dockerfile.trusty-mpich-x64 . ; echo "" && echo '[Press Return to Close]' && read " &

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
