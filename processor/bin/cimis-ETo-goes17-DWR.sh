#!/bin/bash
#
# Run the grass command three times in the event there is an issue
# with the cimis station data pull sleeping 5 minutes between attempts

function cimis ()
{
grass -c ~/gdb17/cimis/$(date --date=yesterday +%Y%m%d) --exec g.cimis sec=eto cmd=ETo,html >> ~/logs/g.cimis-eto.$(date --iso).log 2>&1 && grass -c ~/gdb15/cimis/$(date --date=yesterday --iso) --exec g.cimis-dwr cmd=import,zipcode,html >> ~/logs/g.cimis-dwr.$(date --iso).log 2>&1
}

for i in 1 2 3;do
        cimis
        echo "=================================="
        sleep 300
done
