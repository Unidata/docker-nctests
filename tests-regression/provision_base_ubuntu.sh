#!/bin/bash

###
# Install common packages.
###
set -e

apt update
apt -y upgrade
apt -y install --no-install-recommends sudo adduser
apt -y install ca-certificates
##
# Set up a non-root admin to run the tests as.
##

CUSERPASSWORD=${RANDOM}${RANDOM}${RANDOM}
useradd -ms /bin/bash ${CUSER}
adduser ${CUSER} sudo
echo "${CUSER}:${CUSERPWORD}${RANDOM} " | chpasswd
echo "${CUSER} ALL=NOPASSWD: ALL" >> /etc/sudoers

###
# Install some basics.
###
sudo apt-get -y install --no-install-recommends bzip2 g++ gfortran libtool automake autoconf m4 bison flex libcurl4-openssl-dev zlib1g-dev git wget curl libjpeg-dev cmake gdb dos2unix gsl-bin libgsl0-dev udunits-bin libudunits2-0 libudunits2-dev clang zip valgrind python-setuptools-doc make build-essential less unzip patch libsz2 libssl-dev cmake libxml2 libxml2-dev mpich nano libmpich-dev graphviz doxygen

# bpytop is not packaged for i686/i386 in Ubuntu 24.04; skip on 32-bit builds.
if [ "$(uname -m)" != "i686" ] && [ "$(uname -m)" != "i386" ]; then
    sudo apt-get -y install --no-install-recommends bpytop
fi

###
# Custom mpich installs
###
#sudo bash -x  /root/install_mpich.sh -v 4.3.0 -j $(nproc)

###
# Custom libaec install so that we get cmake config files.
###
git clone https://gitlab.dkrz.de/k202009/libaec.git
cd libaec
git checkout $(git tag -l | tail -n 1)
mkdir build
cd build
cmake ..
make -j $(nproc)
sudo make install
cd ..
cd ..
rm -rf libaec


##
# Some cleanup
##
rm -rf /var/lib/apt/lists/*
