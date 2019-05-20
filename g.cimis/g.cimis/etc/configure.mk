#! /usr/bin/make -f
SHELL:=/bin/bash

# Are we currently Running Grass?
ifndef GISBASE
  $(error Must be running in GRASS)
endif

# Check configuration file.
GOES_SOURCE:=$(shell g.gisenv get=GOES_SOURCE)
ifneq "${GOES_SOURCE}" "16"
ifneq "${GOES_SOURCE}" "17"
  $(error ~/.grass7/rc must have GOES_SOURCE(=${GOES_SOURCE}) set, and equal to 16 or 17, eg g.gisenv set=GOES_SOURCE=17)
endif
endif

ET_URL:=$(shell g.gisenv get=ET_URL)
ifndef ET_URL
  $(error ~/.grass7/rc must have ET_URL, eg g.gisenv set=ET_URL=https://et.water.ca.gov/api)
endif

ET_APPKEY:=$(shell g.gisenv get=ET_APPKEY)
ifndef ET_APPKEY
  $(error ~/.grass7/rc must have ET_APPKEY, eg g.gisenv set=ET_APPKEY=12345-....)
endif

##############  File Organization ################
# GOES16
goes.loc.16:=goes16
import.wld:=501.004322\n0\n0\n-501.004322\n-3871009.893933\n3969206.741045
htdocs.16:=/var/www/goes16/cimis

#GOES17 Parameters
goes.loc.17:=goes17
import.wld.17:=501.004322\n0\n0\n-501.004322\n834923.702613\n4069407.605445
htdocs.17:=/var/www/goes17/cimis

# GOES15 Parameters
htdocs.15:=/var/www/cimis

# CA Solar
solar.loc:=solar
solar.proj.method:=lanczos
# Can set region to default '-d' or explicitly
#solar.region:=-d
solar.region:=-d n=512000 s=-768000 e=640000 w=-512000 res=500

#CIMIS
cimis.loc:=cimis
state:=state@500m
Z:=Z@500m

##############  File Organization ################

####### AGNOSTIC #######
goes.loc:=${goes.loc.${GOES_SOURCE}}
import.wld:=${import.wld.${GOES_SOURCE}}

GISDBASE:=$(shell g.gisenv get=GISDBASE)
LOCATION_NAME:=$(shell g.gisenv get=LOCATION_NAME)
MAPSET:=$(shell g.gisenv get=MAPSET)

###########
# This calls g.mapset if needed
# use like 
# foo:
#   $(call g.mapset,${location},${mapset})
#############

define g.mapset
[[ `g.gisenv LOCATION_NAME` = "$1" && `g.gisenv MAPSET` = "$2" ]] || g.mapset --quiet location=$1 mapset=$2
endef

define g.mapset-c
[[ `g.gisenv LOCATION_NAME` = "$1" && `g.gisenv MAPSET` = "$2" ]] || g.mapset --quiet -c location=$1 mapset=$2 && g.region -d
endef

# This should be deprecated, so we can alse run make routines that span
# multiple mapsets.
#
# Check on whether the MAPSET is a day, month, or otherwise
YYYY:=$(shell echo $(MAPSET) | perl -n -e '/^(20\d{2})(([01]\d)(([0123]\d))?)?$$/ and print $$1;')
MM:=$(shell echo $(MAPSET) | perl -n -e '/^(20\d{2})(([01]\d)(([0123]\d))?)?$$/ and print $$3;')
DD:=$(shell echo $(MAPSET) | perl -n -e '/^(20\d{2})(([01]\d)(([0123]\d))?)?$$/ and print $$5;')

# Shortcut Directories
loc:=$(GISDBASE)/$(LOCATION_NAME)
rast:=$(loc)/$(MAPSET)/cellhd
vect:=$(loc)/$(MAPSET)/vector
site_lists:=$(loc)/$(MAPSET)/site_lists
# etc is our special location for non-grass datafiles
etc:=$(loc)/$(MAPSET)/etc

SQLITE:=sqlite3
db.connect.database:=${loc}/${MAPSET}/sqlite.db

.PHONY: info
info::
	@echo "#### g.gisenv: ####" 
	@g.gisenv;
	@echo "#### g.gisenv: ####" 
	@echo "goes.loc: ${goes.loc}"
	@echo YYYYMMDD: $(YYYY)$(MM)$(DD)

#########################################################################
# Add default colors to a layer
#
# $(rast)/foo:
#	..something to make foo..
#	$(call colorize,$(notdir $@))
#########################################################################
define colorize
	@r.colors map=${1} rast=${1}@default_colors &>/dev/null
endef

#########################################################################
# Allow Shorthand notations, so we can call rasters by their name.
#
# Use like this...
#$(foreach p,foo bar baz,$(eval $(call grass_raster_shorthand,$(p))))
#########################################################################
define grass_raster_shorthand
.PHONY: $(1)
$(1): $(rast)/$(1)
endef

define grass_vect_shorthand
.PHONY: $(1)
$(1): $(vect)/$(1)
endef

##############################################################################
# MASK defines
##############################################################################
define MASK
	(g.findfile element=cellhd file=MASK > /dev/null || g.copy --quiet raster=${state},MASK);
endef

define NOMASK
	if ( g.findfile element=cellhd file=MASK > /dev/null); then g.remove -f --quiet type=rast name=MASK; fi;
endef

.PHONY:clean

clean::
	@echo Nothing to clean in configure.mk
