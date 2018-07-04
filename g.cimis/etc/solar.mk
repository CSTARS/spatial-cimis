#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

solar.mk:=1

ifneq (${LOCATION_NAME},${solar.loc})
  $(error LOCATION_NAME,${LOCATION_NAME} neq ${goes.loc})
endif

rasters:=$(echo ${rast})

info::
	@echo solar.mk
	@echo Calculate Solar Parameters
	@echo rasters:${rasters}
