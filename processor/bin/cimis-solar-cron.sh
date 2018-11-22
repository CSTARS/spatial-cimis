#!/bin/bash
grass -c ~/gdb/solar/$(date +%Y%m%d) --exec make --directory=~/spatial-cimis/g.cimis/etc/ -f solar.mk solar $1
