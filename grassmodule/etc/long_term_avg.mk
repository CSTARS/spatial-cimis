#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

long_term_avg.mk:=1

# Define some .PHONY raster interpolation targets
$(foreach p,ETo_ltx ETo_lts,$(eval $(call grass_raster_shorthand,$(p))))

$(rast)/ETo_s1:
	maps=( `cg.proximate.mapsets --quote --past=7 --future=7 --delim=' ' rast=ETo` ); \
	maps=$$(printf '+%s' "$${maps[@]}"); \
	maps=$${maps:1}; \
	r.mapcalc "ETo_s1=($$maps)" &> /dev/null

$(rast)/ETo_s2:
	maps=( `cg.proximate.mapsets --quote --past=7 --future=7 --delim=' ' rast=ETo` ); \
	maps=$$(printf '+%s^2' "$${maps[@]}"); \
	maps=$${maps:1}; \
	cnt=$${#maps[@]}; \
	r.mapcalc "ETo_s2=($$maps)"

$(rast)/ETo_ltx: $(rast)/ETo_s1
	maps=( `cg.proximate.mapsets --quote --past=7 --future=7 --delim=' ' rast=ETo` ); \
	cnt=$${#maps[@]}; \
	r.mapcalc "ETo_ltx=ETo_s1/$$cnt" &> /dev/null

$(rast)/ETo_lts: $(rast)/ETo_s2 $(rast)/ETo_s1
	maps=( `cg.proximate.mapsets --quote --past=7 --future=7 --delim=' ' rast=ETo` ); \
	cnt=$${#maps[@]}; \
	r.mapcalc "ETo_lts=sqrt(($$cnt*ETo_s2+ETo_s1^2)/$$cnt*($$cnt-1))" &> /dev/null



