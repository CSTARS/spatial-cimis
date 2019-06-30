#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

ifndef solar_functions.mk
include solar_functions.mk
endif

daily_solar.mk:=1

ifneq (${LOCATION_NAME},${solar.loc})
  $(error LOCATION_NAME ${LOCATION_NAME} neq ${goes.loc})
endif

# Check this is a YYYY-MM-DD setup
ifndef DD
$(error MAPSET ${MAPSET} is not YYYYMMDD)
endif

rasters:=$(shell g.list type=rast pattern=????PST-B2)

info::
	@echo daily_solar.mk
	@echo Calculate Solar Parameters
	@echo rast:${rast}
	@echo rasters:${rasters}
#	$(foreach r,${rasters},echo $r:$(shell ./g.cimist risedayset $r);)

# Solar calculates the solar parameters for any given raster
# Below, we loop over all rasters and recalculate solar parameters
# This is for redoing a complete day, not calculating data instantly.
$(eval $(call mapset_targets,${MAPSET}))
$(foreach f,${rasters},$(info B2:$f@${MAPSET}) $(eval $(call next_solar_calc,$f,${MAPSET})))
