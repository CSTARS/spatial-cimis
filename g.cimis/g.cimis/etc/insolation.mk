#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

insolation.mk:=1

calc=r.mapcalc --overwrite --quiet expression="$1=$(subst ",\",$2)"

# Define some .PHONY raster interpolation targets
$(foreach p,FAO_Rso Rnl Rso Rs K ,$(eval $(call grass_raster_shorthand,$(p))))

clean:: clean-tmp
	g.remove rast=Rs,B,D,Bc,Dc,Bk,Dk,Rso,G,K,Bc,Dc,Gc,Trb,Trd,FAO_Rso &> /dev/null
	g.mremove -f rast=[knp]????


# Wh/m^2 day -> MJ/m^2 day
${rast}/Rso: ${GISDBASE}/${solar.loc}/${MAPSET}/cellhd/ssetr-Gc
	ln -s ${GISDBASE}/${solar.loc}/${MAPSET} ${GISDBASE}/${cimis.loc}/_solar${MAPSET}
	$(call calc,Rso,'ssetr-Gc@_solar${MAPSET}'*0.0036);\
	r.colors --quiet map=Rso rast=Rso@default_colors
	rm ${GISDBASE}/${cimis.loc}/_solar${MAPSET}

${rast}/Rs: ${GISDBASE}/${solar.loc}/${MAPSET}/cellhd/ssetr-G
	ln -s ${GISDBASE}/${solar.loc}/${MAPSET} ${GISDBASE}/${cimis.loc}/_solar${MAPSET}
	$(call calc,Rs,'ssetr-G@_solar${MAPSET}'*0.0036);\
	r.colors --quiet map=Rs rast=Rs@default_colors;
	rm ${GISDBASE}/${cimis.loc}/_solar${MAPSET}

${rast}/K: ${rast}/Rs ${rast}/Rso
	$(call calc,K,Rs/Rso);

########################################################################
# This is the CIMIS method of calculating the Extraterrestrial Radiation
#############################################################################
c_day_parms:=year=${YYYY} month=${MM} day=${DD}

# Sunrise/Sunset parameters are taken from r.solpos
${rast}/ssha:
	r.solpos ${c_day_parms} ssha=ssha

${rast}/FAO_Rso: ${rast}/ssha
	@$(call NOMASK)\
	eval `r.solpos -r ${c_day_parms}`; \
	$(call calc,FAO_Rso,(0.0036)*(0.75+0.00002*'Z@500m')*$$etrn*24/3.14159*((ssha*3.14159/180)*sin(latitude_deg@500m)*sin($$declin)+cos(latitude_deg@500m)*cos($$declin)*sin(ssha)));\
	@r.colors map=$(notdir $<) rast=Rso@default_colors > /dev/null

clean::
	@g.remove rast=Rnl;

${rast}/Rnl: ${rast}/Tx ${rast}/Tn ${rast}/ea ${rast}/K
	$(call calc,Rnl,-(1.35*K-0.35)*(0.34-0.14*sqrt(ea))*4.9e-9*(((Tx+273.16)^4+(Tn+273.16)^4)/2))
