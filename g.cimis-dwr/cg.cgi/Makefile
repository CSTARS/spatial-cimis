MODULE_TOPDIR = ../..

# This program supports the wms.cgi script
PGM = cg.cgi

include $(MODULE_TOPDIR)/include/Make/Script.make

default: script

# For bash Script
$(SCRIPTDIR)/%: % | $(SCRIPTDIR)
	$(INSTALL) $< $@
