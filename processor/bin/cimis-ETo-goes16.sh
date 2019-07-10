#!/bin/bash
#
# Run the grass command three times in the event there is an issue
# with the cimis station data pull sleeping 5 minutes between attempts

function cimis ()
{
grass -c ~/gdb/cimis/$(date +%Y%m%d --date="yesterday") --exec make --directory=~/spatial-cimis/g.cimis/etc/ -f cimis.mk ETo html $1
}

for i in 1 2 3;do
        cimis
        echo "=================================="
        sleep 300
done
