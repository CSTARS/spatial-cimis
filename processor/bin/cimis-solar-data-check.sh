#!/bin/bash

# Checks for bad data by looking at the min and max

day=$(date +%Y%m%d)
#day=20181127

function get-all ()
{
for i in `grass ~/gdb/solar/$day --exec g.list rast 2>&1 |grep -E '^s[rs]|PST|^_'`;do 
	echo -n $i
	grass ~/gdb/solar/$day --exec r.info $i 2>&1 |grep "data:" 
done
}
function get-p ()
{
for i in `grass ~/gdb/solar/$day --exec g.list rast 2>&1 |grep -E '^s[rs]|PST-P'`;do 
	echo -n $i
	grass ~/gdb/solar/$day --exec r.info $i 2>&1 |grep "data:" 
done
}

if [[ $1 = all ]]; then
        get-all
elif [[ $1 = "" ]];then
        get-p
else
        echo "Usage:  cimis-solar-data-check.sh [all]"
fi
