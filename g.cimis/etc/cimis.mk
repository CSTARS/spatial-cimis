#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

ifndef interpolate.mk
include interpolate.mk
endif

ifndef insolation.mk
include insolation.mk
endif

ifndef png.mk
include png.mk
endif

cimis.mk:=1

calc=r.mapcalc --overwrite --quiet expression="$1=$2"

$(foreach p,ETo FAO_ETo,$(eval $(call grass_raster_shorthand,$(p))))

#######################################################################
# Finally make the ETo calculation
#######################################################################
clean::
	g.remove rast=ETo,FAO_ETo

DEL:=(4098.17*0.6108*(exp(Tm*17.27/(Tm+237.3)))/(Tm+237.3)^2)
GAM:=psychrometric_constant@500m

ETo=(900.0*${GAM}/(Tm+273)*U2*(es-ea)+0.408*${DEL}*($1*(1.0-0.23)+Rnl))/(${DEL}+${GAM}*(1.0+0.34*U2))

V.info:=@

$(rast)/ETo: $(rast)/Rs $(rast)/Rnl $(rast)/ea $(rast)/Tx $(rast)/Tn $(rast)/U2 $(rast)/Tm $(rast)/es
	${V.info}$(call calc,ETo,$(call ETo,Rs));\
	r.colors --quiet map=$(notdir $@) rast=$(notdir $@)@default_colors

$(rast)/FAO_ETo: $(rast)/FAO_Rso $(rast)/ea $(rast)/Tx $(rast)/Tn $(rast)/U2 $(rast)/Tm $(rast)/es
	${V.info}$(call calc,FAO_ETo,$(call ETo,FAO_Rso*K));\
	r.colors --quiet map=$(notdir $@) rast=ETo@default_colors

.PHONY:clean-rast

clean-rast::
	${V.info}echo "Removing ALMOST all rasters"
	${V.info}tmp=`g.mlist type=rast pattern=* | grep -v '^vis....$$' | grep -v '^vis...._[0-9]$$' | tr "\n" ','`; \
	if [[ $$tmp != ',' && $$tmp != '' ]]; then \
	echo "g.remove rast=$$tmp";\
	g.remove rast=$$tmp > /dev/null;\
	else \
	echo None in MAPSET; \
	fi;
