#!/bin/bash

#/usr/local/grb-box/goesctl ca="$(echo /home/cimis/CA/20190529T*-B2.pgm)" push
/usr/local/grb-box/goesctl ca="$(echo /home/cimis/CA/`date +%Y%m%d`T*-B2.pgm)" push
