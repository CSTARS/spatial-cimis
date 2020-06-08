#!/bin/bash

# clean the temp solar calculation data
# leave essential data required to recalculate ETo

#grass -c ~/gdb/solar/$(date +%Y%m%d --date="last-week") --exec make --directory=~/spatial-cimis/g.cimis/etc/ -f solar.mk clean-tmp $1

cleanday ()
{
/usr/local/bin/grass -c ~/gdb/solar/$day --exec g.remove -f type=rast pattern=_hel*
/usr/local/bin/grass -c ~/gdb/solar/$day --exec g.remove -f type=rast pattern=*????PST-G*
/usr/local/bin/grass -c ~/gdb/solar/$day --exec g.remove -f type=rast pattern=*????PST-K*
}

if [[ $1 = [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]];then
	day=$1
	cleanday
elif [[ $1 = "" ]];then
	day=$(date +%Y%m%d --date="last--week")
	cleanday
else
  echo "Usage:  cimis-solar-clean-cron.sh [YYYYMMDD]"
  echo ""
  echo "Default is last week"
fi

