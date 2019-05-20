MODULE_TOPDIR = ../..

PGM = g.solar_time

include $(MODULE_TOPDIR)/include/Make/Script.make

default: script

# For bash Script
$(SCRIPTDIR)/%: % | $(SCRIPTDIR)
	$(INSTALL) $< $@
