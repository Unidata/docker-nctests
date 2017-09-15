#!/bin/bash
#
# Utility script to recreate dockerfiles from a template.
#

###
# Create Ubuntu Dockerfiles.
###

###
# Wily
###
./create_dockerfile.sh templates/Dockerfile.apt.generic "ubuntu:xenial" xenial-x64
./create_dockerfile.sh templates/Dockerfile.apt.generic "tanosi/ubuntu-xenial-i386" xenial-x86

###
# Trusty
###
./create_dockerfile.sh templates/Dockerfile.apt.generic "ubuntu:trusty" trusty-x64
./create_dockerfile.sh templates/Dockerfile.apt.generic "f69m\/ubuntu32:trusty" trusty-x86

###
# Trusty - Parallel
###
./create_dockerfile.sh templates/Dockerfile.apt.openmpi.generic "ubuntu:xenial" xenial-openmpi-x64
./create_dockerfile.sh templates/Dockerfile.apt.mpich.generic "ubuntu:xenial" xenial-mpich-x64

###
# Create Fedora and Centos Dockerfiles
###
./create_dockerfile.sh templates/Dockerfile.dnf.generic "fedora:23" fedora23-x64
./create_dockerfile.sh templates/Dockerfile.dnf.generic "fedora:22" fedora22-x64

./create_dockerfile.sh templates/Dockerfile.yum.generic "fedora:21" fedora21-x64
./create_dockerfile.sh templates/Dockerfile.yum.generic "centos:7" centos7-x64
