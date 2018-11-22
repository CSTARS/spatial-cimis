#!/bin/bash
grass -c ~/gdb/solar/$(date +%Y%m%d --date="yesterday") --exec make --directory=~/spatial-cimis/g.cimis/etc/ -f solar.mk clean-tmp $1
