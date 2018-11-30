#!/bin/bash

# Checks for bad data by looking at the min and max

day=$(date +%Y%m%d)
#day=20181127

for i in `grass ~/gdb/solar/$day --exec g.list rast 2>&1 |grep -E '^s[rs]|PST-P'`;do 
	echo -n $i
	grass ~/gdb/solar/$day --exec r.info $i 2>&1 |grep "data:" 
done
