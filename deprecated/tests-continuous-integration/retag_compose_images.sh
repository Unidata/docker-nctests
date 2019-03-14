#!/bin/bash
#
# Utility script to rename the images
# built by docker compose to adopt the
# naming convention I'd been using.

set -e
set -x

docker tag dockerfileci_fedora21       unidata/ncci:fedora21-x64
docker tag dockerfileci_fedora22       unidata/ncci:fedora22-x64
docker tag dockerfileci_fedora23       unidata/ncci:fedora23-x64
docker tag dockerfileci_centos7        unidata/ncci:centos7-x64
docker tag dockerfileci_trusty-openmpi unidata/ncci:trusty-openmpi-x64
docker tag dockerfileci_trusty-mpich   unidata/ncci:trusty-mpich-x64
docker tag dockerfileci_trusty64       unidata/ncci:trusty-x64
docker tag dockerfileci_trusty32       unidata/ncci:trusty-x86
docker tag dockerfileci_wily64         unidata/ncci:wily-x64
docker tag dockerfileci_wily32         unidata/ncci:wily-x86
