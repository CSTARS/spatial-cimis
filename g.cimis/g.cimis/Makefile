MODULE_TOPDIR = ../..

PGM = g.cimis

include $(MODULE_TOPDIR)/include/Make/Script.make

ETCFILES = $(shell cd etc; echo *.mk)

DSTFILES := $(patsubst %,$(ETC)/${PGM}/%,$(ETCFILES))

default: script $(DSTFILES)

$(ETC)/${PGM}/%: etc/% $(ETC)/${PGM}
	$(INSTALL) $< $@

