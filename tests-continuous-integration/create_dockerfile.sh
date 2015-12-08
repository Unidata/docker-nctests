#!/bin/bash


DOHELP()
{
    echo "Usage: $0 [template file] [base image name] [Dockerfile suffix]"
    echo ""
    echo "Example:"
    echo -e "\t $0 Dockerfile.ubuntu.generic ubuntu:trusty trusty.x64"
    echo ""
}

if [ $# -lt 3 ]; then
    DOHELP
    exit 1
fi


INFILE="${1}"
BASENAME="${2}"
SUFF="${3}"

OUTFILE="Dockerfile.${SUFF}"

OS=$(uname)

SEDARGS=""

if [ "x$OS" == "xDarwin" ]; then
    SEDARGS=".bak"
fi

cp "${INFILE}" "${OUTFILE}"
sed -i ${SEDARGS} "s/GENERIC-CONTAINER/${BASENAME}/g" ${OUTFILE}
rm -f "${OUTFILE}".bak

echo "Created ${OUTFILE}"
echo ""
