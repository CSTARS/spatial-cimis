#!/bin/bash
#
# Run the grass command three times in the event there is an issue
# with the cimis station data pull sleeping 5 minutes between attempts

function cimis ()
{
grass -c ~/gdb17/cimis/$(date --date=yesterday +%Y%m%d) --exec g.cimis sec=eto cmd=ETo,html >> ~/logs/g.cimis-eto.$(date --iso).log 2>&1 
}

for i in 1 2 3;do
        cimis
        echo "=================================="
        sleep 300
done
