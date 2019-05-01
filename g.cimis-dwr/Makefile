MODULE_TOPDIR =../..

PGM = g.cimis-dwr

SUBDIRS = cg.cgi cg.zipcode.summary

include $(MODULE_TOPDIR)/include/Make/Dir.make

default: parsubdirs htmldir

install: installsubdirs
	$(INSTALL_DATA) $(PGM).html $(INST_DIR)/docs/html/
