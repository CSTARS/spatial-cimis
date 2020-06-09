#! /usr/bin/make -f 

ifndef configure.mk
include configure.mk
endif

zipcode.mk:=1

parms:=Rs ETo K Rnl Tx Tn U2 Rso
#parms:=Rs ETo

.PHONY: info
info::
	@echo zipcode.mk - Create zipcode summaries for a particular day.  Add to SQLite db

.PHONY:zipcode

zipcode: $(etc)/zipcode.db
$(etc)/zipcode.csv: 
	g.region rast=zipcode_2012@zipcode;
	cg.zipcode.summary --noheader --nocount rast=Tn,Tx,U2,ea,Gc,G,K,Rnl,ETo > $@;\
	g.region -d;

$(etc)/zipcode.db: $(etc)/zipcode.csv
	echo -e "delete from zipcode_daily where d_date='$(MAPSET)';\n.mode csv\n.import $< zipcode_daily\n.quit" | ${sqlite}; \
	if [[ $$? == 0 ]] ; then touch $@; fi 


