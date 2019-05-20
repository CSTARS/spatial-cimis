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

ifndef daily_solar.mk
include daily_solar.mk
endif

ifndef eto.mk
include eto.mk
endif

g.cimis.mk:=1

