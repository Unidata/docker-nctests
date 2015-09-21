#!/bin/bash
#
# Depends on docker-squash utility found at:
# - https://github.com/jwilder/docker-squash
#
# Note that there is a markdown file with OSX-specific
# instructions.

set -e

DOHELP()
{
    echo "Usage: $0 [suffix]"
    echo ""
    echo "Suffix for loading script that is generated."
    echo ""
}

if [ $# -lt 1 ]; then
    DOHELP
    exit 1
fi

OUTSCRIPT="load-docker-images-${1}.sh"

PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"

IMGS="unidata/nctests:base \
unidata/nctests:base32 \
unidata/nctests:serial \
unidata/nctests:serial32 \
unidata/nctests:mpich \
unidata/nctests:mpich32 \
unidata/nctests:openmpi \
unidata/nctests:openmpi32"

echo "#!/bin/bash" > ${OUTSCRIPT}
echo "#" $(date) >> ${OUTSCRIPT}
echo "#" >> ${OUTSCRIPT}
for X in $IMGS; do
    echo $X
    OUTNAME=$(echo $X | sed "s/:/-/g" | sed "s/\//_/g").tar

    echo "Squashing ${X} to ${OUTNAME}"
    docker save $X | sudo docker-squash -verbose -t $X -o ${OUTNAME}
    sudo chown wfisher:wfisher ${OUTNAME}
    echo "Loading ${OUTNAME}"
    docker load -i ${OUTNAME}
    echo ""

    # Add to loading script.
    echo "echo Loading ${OUTNAME} as ${X}" >> ${OUTSCRIPT}
    echo "docker load -i ${OUTNAME}" >> ${OUTSCRIPT}
    echo "echo" >> ${OUTSCRIPT}

done
chmod 755 ${OUTSCRIPT}

echo "echo Finished" >> ${OUTSCRIPT}

sudo chown wfisher:wfisher ${OUTSCRIPT}
echo ""
echo "Created utility loading script ${OUTSCRIPT}."
echo ""
echo "Finished."
