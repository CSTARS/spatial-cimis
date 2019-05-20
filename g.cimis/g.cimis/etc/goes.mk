#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

ifndef solar_functions.mk
include solar_functions.mk
endif

goes.mk:=1

# Handy oneline functions
f_fn=$(notdir $(basename $1))
f_mapset=$(word 1,$(subst T, ,$(call f_fn,$1)))
f_rastname=$(word 2,$(subst T, ,$(call f_fn,$1)))T$(word 3,$(subst T, ,$(call f_fn,$1)))

f_goes_rast=${GISDBASE}/${goes.loc}/$(call f_mapset,$1)/cellhd/$(call f_rastname,$1)
f_solar_rast=${GISDBASE}/${solar.loc}/$(call f_mapset,$1)/cellhd/$(call f_rastname,$1)

#files:=$(wildcard /home/cimis/CA/*.pgm)
mapsets:=$(sort $(foreach f,${files},$(call f_mapset,$f)))

info::
	@echo goes.mk
	@echo "Import GOES data into Grass"
	@echo filenames:${filenames}
	@echo mapset:${mapsets}
	@echo $(call f_mapset,$(firstword ${files}))
	@echo $(call f_rast,$(firstword ${files}))

.PHONY: import solar goes_to_solar

define _import
$(eval rast:=${GISDBASE}/${solar.loc}/$(call f_mapset,$1)/cellhd)
import::$(call f_goes_rast,$1)
	@echo "imported"

$(call f_goes_rast,$1):$1
	@$(call g.mapset-c,${goes.loc},$(call f_mapset,$1));\
	echo -e '${import.wld}' > $(patsubst %.pgm,%.wld,$1);\
	r.in.gdal --quiet --overwrite -o input=$1 output=$(call f_rastname,$1);\
	rm $(patsubst %.pgm,%.wld,$1);\
	echo ${goes.loc}/$(call f_mapset,$1)/$(call f_rastname,$1)

endef

define _goes_to_solar
$(eval rast:=${GISDBASE}/${solar.loc}/$(call f_mapset,$1)/cellhd)

goes_to_solar::$(call f_solar_rast,$1)

$(call f_solar_rast,$1):$(call f_goes_rast,$1)
	@$(call g.mapset-c,${solar.loc},$(call f_mapset,$1));\
	g.region --quiet ${solar.region};\
	r.proj --quiet location=${goes.loc} mapset=$(call f_mapset,$1) \
	  input=$(call f_rastname,$1) method=${solar.proj.method};\
	echo ${solar.loc}/$(call f_mapset,$1)/$(call f_rastname,$1)

endef

define _add_night
$(eval $(call _import,$1))
endef

define _add_day

$(eval $(call _import,$1))
$(eval $(call _goes_to_solar,$1))
# This adds in 'solar' rule.  Can't use with daily_solar as well,
# It would get overwritten.
$(eval $(call next_solar_calc,$(call f_rastname,$1),$(call f_mapset,$1)))

endef

define _add_sunrise
$(call _add_day,$1)
endef

define _add_sunset
$(call _add_day,$1)
endef

# We have to be in the solar location to get proper sunrise time.
define import
$(eval tod:=$(shell $(call g.mapset-c,${solar.loc},$(call f_mapset,$1)); g.solar_time cmd=risedayset mapset=$(call f_mapset,$1) rast=$(call f_rastname,$1)))
$(call _add_$(firstword ${tod}),$1)
endef

$(foreach m,$(sort $(foreach f,${files},$(call f_mapset,$f))),$(eval $(call mapset_targets,$m)))
$(foreach f,$(filter %.pgm,${files}),$(eval $(call import,$f)))
