#!/bin/bash
# Script to remove all 'nightly' test directories.
# assumes these directories live in /machine/wfisher
#
# Add to cron as:
# 4 5 * * 0 /path/to/this/script

if [ ! -d /machine/wfisher ]; then
    exit 0
fi

cd /machine/wfisher

rm -rf netcdf-nightly-14*

echo `date` > cleaned_test_directory.txt
