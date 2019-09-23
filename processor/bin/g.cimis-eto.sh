#!/bin/bash
#
function eto ()
{
	        /usr/local/bin/grass -c /home/cimis/gdb17/cimis/$(date --date=yesterday +%Y%m%d) --exec g.cimis sec=eto cmd=ETo,html
}
function eto-custom ()
{
        /usr/local/bin/grass -c /home/cimis/gdb17/cimis/$day --exec g.cimis sec=eto cmd=ETo,html
}
function eto-dwr ()
{
        /usr/local/bin/grass -c ~/gdb15/cimis/$(date --date=yesterday --iso) --exec g.cimis-dwr cmd=import,zipcode,html
}
function eto-dwr-custom ()
{
        /usr/local/bin/grass -c ~/gdb15/cimis/$(date --date=$day --iso) --exec g.cimis-dwr cmd=import,zipcode,html
}

if [[ $1 = [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]];then
        day=$1
        eto-custom
        eto-dwr-custom
elif [[ $1 = "" ]];then
        eto
        eto-dwr
else
        echo
        echo "Usage:  g.cimis-eto [YYYYMMDD]"
        echo
        echo "        Default date is yesterday"
        echo
fi
