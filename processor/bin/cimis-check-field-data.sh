#!/bin/bash

# query yesterday's imported field data
# if last column value is "A" indicates "average" or bad data

grass ~/gdb/cimis/`date +%Y%m%d --date="yesterday"` --exec v.out.ascii columns=day_asce_eto,day_asce_eto_qc input=et@`date +%Y%m%d --date="yesterday"`
