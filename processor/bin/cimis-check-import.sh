#!/bin/bash

# check if today's bands were imported
# if not run without -n option

grass /home/cimis/gdb/goes16/cimis --exec /home/cimis/spatial-cimis/g.cimis/etc/goes.mk --directory=/home/cimis/spatial-cimis/g.cimis/etc files="$(echo /home/cimis/CA/`date +%Y%m%d`T*-B2.pgm)"  import solar -n
