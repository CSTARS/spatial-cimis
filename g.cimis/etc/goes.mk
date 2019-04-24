#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

goes.mk:=1

ifneq (${LOCATION_NAME},${goes.loc})
  $(error LOCATION_NAME,${LOCATION_NAME} neq ${goes.loc})
endif

# Handy oneline functions
f_fn=$(notdir $(basename $1))
f_mapset=$(word 1,$(subst T, ,$(call f_fn,$1)))
f_rastname=$(word 2,$(subst T, ,$(call f_fn,$1)))T$(word 3,$(subst T, ,$(call f_fn,$1)))
f_rast=${loc}/$(call f_mapset,$1)/cellhd/$(call f_rastname,$1)
f_solar_rast=${GISDBASE}/${solar.loc}/$(call f_mapset,$1)/cellhd/$(call f_rastname,$1)


files:=$(wildcard /home/quinn/CA/*.pgm)
mapsets:=$(sort $(foreach f,${files},$(call f_mapset,$f)))

info::
	@echo goes.mk
	@echo "Import GOES data into Grass"
	@echo filenames:${filenames}
	@echo mapset:${mapsets}
	@echo $(call f_mapset,$(firstword ${files}))
	@echo $(call f_rast,$(firstword ${files}))

mapsets.dirs:=$(patsubst %,${loc}/%,${mapsets})

.PHONY: mapset import
mapset:${mapsets.dirs}

${mapsets.dirs}:${loc}/%:
	g.mapset -c $*

.PHONY: import solar
import::
solar::

define import
import::$(call f_rast,$1)

$(call f_rast,$1):$1
	g.mapset -c $(call f_mapset,$1);
	echo -e '${import.wld}' > $(patsubst %.pgm,%.wld,$1);\
	r.in.gdal --overwrite -o input=$1 output=$(call f_rastname,$1);\
	rm $(patsubst %.pgm,%.wld,$1);

solar::$(call f_solar_rast,$1)

$(call f_solar_rast,$1):$(call f_rast,$1)
	g.mapset -c location=${solar.loc} mapset=$(call f_mapset,$1);\
	g.region ${solar.region};\
	r.proj location=${goes.loc} mapset=$(call f_mapset,$1) \
	  input=$(call f_rastname,$1) method=${solar.proj.method};
endef

$(foreach f,$(filter %.pgm,${files}),$(eval $(call import,$f)))
