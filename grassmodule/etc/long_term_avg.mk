#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

long_term_avg.mk:=1

# Define some .PHONY raster interpolation targets

define avg 

$(call grass_raster_shorthand,$1_15_avg)

$(rast)/$1_15avg:
	maps=`cg.proximate.mapsets --past=7 --future=7 --delim=',' rast=$1`; \
	r.series input=$${maps} output=$1_15avg,$1_15min,$1_15max,$1_15stddev method=average,minimum,maximum,stddev

endef

rast:=ETo Rs K Rnl Tn Tx Tdew U2 

$(foreach r,${rast},$(eval $(call avg,$r)))

