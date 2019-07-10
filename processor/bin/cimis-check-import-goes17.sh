#!/bin/bash

# check if today's bands were imported
# if not run without -n option

grass /home/cimis/gdb/goes17/cimis --exec g.cimis sec=goes cmd=import,solar arg="files='$(echo /home/cimis/CA/`date +%Y%m%d`T*-B2.pgm)'" -n
