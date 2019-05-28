#! /usr/bin/make -f

include configure.mk
include zipcode.mk
include png.mk

g.cimis-dwr.mk:=1

save:=ETo K Rnl Rs Rso Tdew Tm Tn Tx U2 ea es
save_comma:=ETo,K,Rnl,Rs,Rso,Tdew,Tm,Tn,Tx,U2,ea,es

mapset.gdb17:=${GISDBASE}/../gdb17/cimis/$(subst -,,${MAPSET})
rast.gdb17:=${mapset.gdb17}/cellhd

.PHONY:import

import:${rast}/ETo
	@echo "${rast}/{${save_comma}}"

${rast}/ETo: ${rast.gdb17}/ETo
	@rm -f ${loc}/TRANSFER; \
	ln -s ${mapset.gdb17} ${loc}/TRANSFER;\
	g.region -d;\
	g.copy --quiet --overwrite vect=et@TRANSFER,et;\
	for m in ${save}; do \
	  if ( !  g.findfile element=cellhd file=$$m > /dev/null); then \
	    r.mapcalc --overwrite --quiet expr="$$m=$$m@TRANSFER";\
	  fi;\
	done; \
	rm -f ${loc}/TRANSFER

