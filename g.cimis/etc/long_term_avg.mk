#! /usr/bin/make -f

#ifndef configure.mk
include configure.mk
#endif

long_term_avg.mk:=1

# Define some .PHONY raster interpolation targets

define avg 

$1_15avg:$(rast)/$1_15avg

$(rast)/$1_15avg:
	maps=`cg.proximate.mapsets --past=7 --future=7 --delim=',' rast=$1`; \
	r.series input=$$$${maps} output=$1_15avg,$1_15min,$1_15max,$1_15stddev method=average,minimum,maximum,stddev

endef

define median

$1_15med:$(rast)/$1_15med

$(rast)/$1_15med:
	maps=`cg.proximate.mapsets --past=7 --future=7 --delim=',' rast=$1`; \
	r.series input=$$$${maps} output=$1_15med method=median

endef

#rast:=ETo Rs K Rnl Tn Tx Tdew U2 FAO_ETo FAO_Rso Rso 
avgs:=ETo FAO_ETo

$(foreach r,${avgs},$(eval $(call avg,$r)))
$(foreach r,${avgs},$(eval $(call median,$r)))

