#!/bin/bash
#
# Utility script to recreate dockerfiles from a template.
#

###
# Create Ubuntu Dockerfiles.
###

###
# Xenial
###
./create_dockerfile.sh templates/Dockerfile.apt.generic "ubuntu:xenial" xenial-x64
./create_dockerfile.sh templates/Dockerfile.apt.generic "tanosi\/ubuntu-xenial-i386" xenial-x86

###
# Xenial - Parallel
###
./create_dockerfile.sh templates/Dockerfile.apt.openmpi.generic "ubuntu:xenial" xenial-openmpi-x64
./create_dockerfile.sh templates/Dockerfile.apt.mpich.generic "ubuntu:xenial" xenial-mpich-x64

###
# Create Fedora and Centos Dockerfiles
###
./create_dockerfile.sh templates/Dockerfile.dnf.generic "fedora:27" fedora27-x64
./create_dockerfile.sh templates/Dockerfile.dnf.generic "fedora:26" fedora26-x64
./create_dockerfile.sh templates/Dockerfile.yum.generic "centos:7" centos7-x64
