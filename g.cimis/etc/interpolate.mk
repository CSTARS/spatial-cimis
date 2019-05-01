#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

ifndef spline.mk
include spline.mk
endif

interpolate.mk:=1

V.info=@

.PHONY: info
info::
	@echo interpolate.mk

calc=r.mapcalc --overwrite --quiet expression="$1=$(subst ",\",$2)"

###############################################################
# All interpolations depend on the etxml vector
##############################################################
et:${vect}/et

${vect}/et:
	db.connect driver=sqlite database='$$GISDBASE/$$LOCATION_NAME/$$MAPSET/sqlite.db'
	v.in.et --overwrite api=${ET_URL} output=et date=${YYYY}-${MM}-${DD}

# Define some .PHONY raster interpolation targets
$(foreach p,U2 Tn Tx Tdew RHx ea es,$(eval $(call grass_raster_shorthand,$(p))))

###############################################################
# U2 uses only the average wind speed spline fit.
##############################################################
clean::
	g.remove rast=U2

$(rast)/U2: ${rast}/day_wind_spd_avg_${tzs}
	${V.info}$(call MASK)\
	$(call calc,U2,$(notdir $<));\
	r.support map=U2 title='U2' units='m/s' \
	description='Daily average windspeed at 2m height' \
	source1='3D spline from CIMIS data';\
	map=$(notdir $@);\
	$(call colorize,$(notdir $@));\
	$(call NOMASK)

# Currently all Temperature estimations (Tn,Tx,Tdew)
# use an average of the lapse rate (?_ns) and daymet (?_dme) interpolations.
# The current implementation uses a different _dme suffix
define avg_T
clean::
	g.remove $(1);

$(rast)/$(1): $(rast)/$(2)_ns
	$(call MASK)\
	$(call calc,$(1),$(2)_ns);\
	r.colors --quiet map=$(1) rast=at@default_colors;\
	$(call NOMASK)
endef

clean::
	g.remove RHx

$(rast)/RHx: $(rast)/day_rel_hum_max_$(tzs)
	$(call MASK)\
	$(call calc,RHx,day_rel_hum_max_$(tzs));\
	r.colors --quiet map=RHx rast=rh@default_colors;\
	$(call NOMASK)

$(eval $(call avg_T,Tn,day_air_tmp_min))
$(eval $(call avg_T,Tx,day_air_tmp_max))
$(eval $(call avg_T,Tdew,day_dew_pnt))

clean::
	g.remove rast=Tm;

$(rast)/Tm: $(rast)/Tx $(rast)/Tn
	$(call calc,Tm,(Tx+Tn)/2.0);

###########################################################################
# es is calculated from min/max at
# ea is calculated two ways,
# - from extrapolated dewpt
# - from Tn * extrapolated RHx.
# Depending on settings, we either use the dewpt or no method.
# Which is set with use_rh_for_ea
###########################################################################
clean::
	g.remove rast=es;

$(rast)/es: $(rast)/Tx $(rast)/Tn
	$(call calc,$(notdir $@),0.6108/2*(exp(Tn*17.27/(Tn+237.3))+exp(Tx*17.27/(Tx+237.3))));\

#use_rh_for_ea:=0  # Comment out to use only dewpt as estimator for ea

ifdef use_rh_for_ea
clean::
	g.remove ea_rh,ea_Tdew,ea,ea_err


$(rast)/ea_rh: $(rast)/RHx $(rast)/Tn
	$(call calc,ea_rh,0.6108*(exp(Tn*17.27/(Tn+237.3))*RHx/100));\

$(rast)/ea_Tdew: $(rast)/Tdew
	$(call calc,$(notdir $@),0.6108*exp($(notdir $<)*17.27/(($(notdir $<)+237.3))));\

$(rast)/ea: $(rast)/ea_Tdew $(rast)/ea_rh
	$(call calc,ea,(ea_Tdew+ea_rh)/2);

$(rast)/ea_err: $(rast)/ea
	$(call calc,ea_err,sqrt(2)*abs(ea-ea_Tdew))

else
clean::
	g.remove rast=ea_dewp_ns;

$(rast)/ea_dewp_ns: $(rast)/day_dew_pnt_ns
	$(call calc,$(notdir $@),0.6108*exp(($(notdir $<)*17.27/(($(notdir $<)+237.30)))));

clean::
	g.remove ea;

$(rast)/ea: $(rast)/ea_dewp_ns
	$(call calc,ea,ea_dewp_ns);

endif # use_rh
