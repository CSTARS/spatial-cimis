#! /usr/bin/make -f 

base:=/home/quinn
CA:=${base}/CA+

raw:=$(wildcard /grb/raw/conus/satimage*.pgm)
# This example limits to the last hour
#raw:=$(shell find /grb/raw/conus/ -newermt $$(date --date='now -1 hours' --iso=seconds) -name \*.pgm)

define pst-fn
$(shell date --date="2000-01-01T12:00 UTC + $$(( 16#$(word 2,$(patsubst T%,%,$(subst -, ,$(notdir $1)))) )) seconds - 8 hours" +%Y%m%dT%H%MPST)
endef

# Old parameters
#b2.crop.ca:=2460x1912!+3121+2925
#b2.crop.conus:=10000x6000!+3608+1688

# These are the various band sizes
B1.size:=1
B2.size:=05
B3.size:=1
B4.size:=2
B5.size:=1
B6.size:=2
B7.size:=2
B8.size:=2
B9.size:=2
B10.size:=2
B11.size:=2
B12.size:=2
B13.size:=2
B14.size:=2
B15.size:=2
B16.size:=2

# Handy functions
band=$(lastword $(subst -, ,$(1:.pgm=)))
size=${$(call band,$1).size}

# These are the cropping values vs band size.
05.crop.ca:=2460x1912!+3121+2925
1.crop.ca:=1230x956!+1560+1462
2.crop.ca:=615x478!+780+731

define ca-rule
CA::${CA}/$(call pst-fn,$1)-$(call band,$1).pgm
${CA}/$(call pst-fn,$1)-$(call band,$1).pgm:$1
	convert -crop ${$(call size,$1).crop.ca} $$< $$@

endef

.PHONY:CA
CA::

$(foreach r,${raw},$(eval $(call ca-rule,$r)))

INFO:
	@echo ${raw}

