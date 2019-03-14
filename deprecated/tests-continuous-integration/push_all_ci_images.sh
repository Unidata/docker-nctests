#!/bin/bash

set -e

docker push unidata/ncci:xenial-x64
docker push unidata/ncci:xenial-x86
docker push unidata/ncci:trusty-x64
docker push unidata/ncci:trusty-x86
docker push unidata/ncci:fedora23-x64
docker push unidata/ncci:fedora22-x64
docker push unidata/ncci:fedora21-x64
docker push unidata/ncci:centos7-x64
docker push unidata/ncci:xenial-openmpi-x64
docker push unidata/ncci:xenial-mpich-x64
