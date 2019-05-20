#! /usr/bin/make -f
SHELL:=/bin/bash

# Are we currently Running Grass?
ifndef GISBASE
  $(error Must be running in GRASS)
endif

# GOES15 Parameters
htdocs:=/var/www/goes15/cimis
state:=state@PERMANENT

##############  File Organization ################

GISDBASE:=$(shell g.gisenv get=GISDBASE)
LOCATION_NAME:=$(shell g.gisenv get=LOCATION_NAME)
MAPSET:=$(shell g.gisenv get=MAPSET)


# Check on whether the MAPSET is a day, month, or otherwise
YYYY:=$(shell echo $(MAPSET) | perl -n -e '/^(20\d{2})-(([01]\d)-(([0123]\d))?)?$$/ and print $$1;')
MM:=$(shell echo $(MAPSET) | perl -n -e '/^(20\d{2})-(([01]\d)-(([0123]\d))?)?$$/ and print $$3;')
DD:=$(shell echo $(MAPSET) | perl -n -e '/^(20\d{2})-(([01]\d)-(([0123]\d))?)?$$/ and print $$5;')

###################################################
# Check for YYYY / MM / DD
##################################################
define hasDD
ifndef DD
$(error MAPSET is not YYYY-MM-DD)
endif
endef


# Shortcut Directories
loc:=$(GISDBASE)/$(LOCATION_NAME)
rast:=$(loc)/$(MAPSET)/cellhd
vect:=$(loc)/$(MAPSET)/vector
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
