#!/bin/bash

###
# Utility script to bring up groups of vagrant machines
# in parallel.  This isn't supported automatically,
# and can cause hangs if two vagrant commands are invoked at
# the same time, so this runs for a group and then sleeps, so
# that the commands end up being staggered.
###

#groups=( "vivid" "unicorn" "trusty" "centos" "fedora" )
groups=( "unicorn" "trusty" "centos" "fedora" )

for i in "${groups[@]}"
do :
   LFILE="$i-log.txt"
   echo "Processing group \"$i\" > $LFILE"
   vagrant up "/$i/" > $LFILE 2>&1 &
   sleep 1
   echo "Opening log file."
   xterm -bg black -fg white -geometry 140x20+10+10 -e tail -f $LFILE &
   echo "Sleeping 30 seconds"
   sleep 30
   echo ""
done


echo ""

echo "Finished"
