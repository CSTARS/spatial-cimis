#!/bin/bash

/usr/local/grb-box/goesctl raw="echo $(find /grb/raw/conus/*-B2.pgm -print0 |sed 's/pgm/pgm /g')" CA
