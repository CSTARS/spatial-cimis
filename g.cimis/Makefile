MODULE_TOPDIR = ../..

PGM = g.cimis

include $(MODULE_TOPDIR)/include/Make/Script.make

ETCFILES = goes.mk
DSTFILES := $(patsubst %,$(ETC)/g.cimis/%,$(ETCFILES))

default: script $(DSTFILES)

$(ETC)/g.cimis/%: etc/% $(ETC)/g.cimis
	$(INSTALL) $< $@

#$(ETC)/g.cimis:
#	$(MKDIR) $@
