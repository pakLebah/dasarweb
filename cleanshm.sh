#!/bin/bash

ME="$1"
# set default to web user
if [ "$ME" == "" ]; then
  ME="www-data"
fi

# list shared memory for given user
echo "Shared memory used by $ME:"
echo ""
echo "------ Shared Memory Segments --------"
echo "key        shmid      owner      perms      bytes      nattch     status"
ipcs -m | grep $ME
echo ""

# remove shared memory belongs to given user
IPCS_M=`ipcs -m | egrep "0x[0-9a-f]+ [0-9]+" | grep $ME | cut -f2 -d" "`
for id in $IPCS_M; do
  ipcrm -m $id;
done

# show the rest of shared memory in-use
echo "Remaining shared memory in-use:"
ipcs -m