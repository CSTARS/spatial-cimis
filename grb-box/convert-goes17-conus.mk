#! /usr/bin/make -f 

base:=/home/cimis
CA:=${base}/CA

raw:=$(wildcard /grb/raw/conus/satimage*-B2.pgm)
# This example limits to the last hour
#raw_conus:=$(shell find /grb/raw/conus/ -newermt $$(date --date='now -1 hours' --iso=seconds) -name \*-B2.pgm)

b2-filtered:=$(filter %-B2.pgm,${raw})

# define iso-fn-via-stat =
# $(shell date --date="$$(date --date=@$$(stat --format='%Z' $1)) - 7 hours" +%Y%m%dT%H%MPST)
# endef

# define iso-date =
# $(shell date --date="2000-01-01T12:00 UTC + $$(( 16#$(patsubst satimage-T%-B2.pgm,%,$(notdir $1)) )) seconds" --iso=seconds)
# endef

define pst-fn =
$(shell date --date="2000-01-01T12:00 UTC + $$(( 16#$(patsubst satimage-T%-B2.pgm,%,$(notdir $1)) )) seconds - 8 hours" +%Y%m%dT%H%MPST)
endef

define ca-rule =
CA::${CA}/$(call pst-fn,$1)-B2.pgm
${CA}/$(call pst-fn,$1)-B2.pgm:$1
	convert -crop ${crop.ca} $$< $$@
endef

crop.ca:=2543x1880!+12514+2725
crop.conus:=10000x6000!+3608+1688

.PHONY:CA
CA::

$(foreach r,${b2-filtered},$(eval $(call ca-rule,$r)))

INFO:
	@echo ${b2-filtered}

