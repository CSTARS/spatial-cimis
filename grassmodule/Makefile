#! /usr/bin/make
# in Debian 
#GH=$(pkg-config --variable=prefix grass) # /usr/lib/grass64
#GRASS_ADDON=~/grass
#mkdir -p ${GRASS_ADDON}/scripts 
#make GRASS_HOME=. MODULE_TOPDIR=${GH} INST_DIR=${GRASS_ADDON} install

MODULE_TOPDIR = ../..
PGM = cg
include $(MODULE_TOPDIR)/include/Make/Script.make

scripts:=cg v.in.et r.heliosat cg.daily.k cg.daylight.intervals cg.previous.mapsets r.lowpass cg.proximate.mapsets cg.cgi cg.daily.rc cg.zipcode.summary cg.ca_daily_vis.rc cg.pushover
ETCDIR=${INST_DIR}/etc/${PGM}

default: install

${ETCDIR}:
	if [ ! -d $(ETCDIR) ]; then $(MKDIR) $(ETCDIR); fi

install: ${ETCDIR}
	$(INSTALL) etc/*.mk ${ETCDIR}
	${INSTALL} $(patsubst %,scripts/%,${scripts}) ${INST_DIR}/scripts
