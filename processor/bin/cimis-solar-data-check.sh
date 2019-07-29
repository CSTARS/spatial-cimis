#!/bin/bash

# Checks for bad data by looking at the min and max for a specific day

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
        # get min and max values; change 0.* to .* for proper monitoring of true 0 integer values
        grass ~/gdb/solar/$day --exec r.info $i 2>&1 |grep "data:" |sed 's/max = 0\./max = \./g'
done
}

if [[ $1 = [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]];then
        day=$1
        if [[ $2 = all ]]; then
                get-all
        elif [[ $2 = "" ]]; then
                get-p
        else
                echo "Usage:  cimis-solar-data-check.sh [YYYYMMDD][all]"
        fi
elif [[ $1 = "" ]];then
        day=$(date +%Y%m%d)
        get-p
elif [[ $1 = "all" ]];then
        day=$(date +%Y%m%d)
        get-all
else
        echo "Usage:  cimis-solar-data-check.sh [YYYYMMDD][all]"
fi
