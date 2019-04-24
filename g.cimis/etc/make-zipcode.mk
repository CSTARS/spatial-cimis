#! /usr/bin/make -f 

ifndef configure.mk
include configure.mk
endif

SQLITE:=sqlite3 ~/cimis.db

zipcode.mk:=1

#parms:=Rs ETo K Rnl Tx Tn U2 Rso
parms:=Rs ETo

.PHONY: info
info::
	@echo zipcode.mk

ifneq (${LOCATION_NAME},WORLD)

ifneq (${MAPSET},PERMANENT)

.PHONY:zipcode

zipcode: $(etc)/zipcode.db
$(etc)/zipcode.db: $(rast)/Tn $(rast)/Tn_err $(rast)/Tx $(rast)/Tx_err $(rast)/U2 $(rast)/U2_err $(rast)/ea $(rast)/ea_err $(rast)/Gc $(rast)/G $(rast)/K $(rast)/Rnl $(etc)/tl $(rast)/ETo $(rast)/FAO_Rso
	g.region rast=zipcode_2012@zipcode;
        (echo date,zipcode,Tn,Tx,U2,ea,Gc,G,K,Rnl,ETo,FAO_Rso;
        cimis.daily.zipcode.summary --nocount rast=Tn,Tx,U2,ea,Gc,G,K,Rnl,ETo,FAO_Rso) > $*
        g.region -d;

$(etc)/zipcode.db: $(etc)/zipcode.csv
        echo "delete from zipcode_daily where d_date='$(MAPSET)'; .mode csv; .import $* zipcode_daily;" | $(SQLITE); 
        touch $@;

else

.PHONY:zcta510_2012
zcta510_2012:${vect}/zcta510_2012

${vect}/zcta510_2012:${GISDBASE}/WORLD/zipcode/vector/tl_2012_zcta510_CA
	v.proj input=$(notdir $<) location=WORLD mapset=zipcode output=$(notdir $@); \
	db.dropcol -f table=zcta510_2012 column=INTPTLAT10; \
	db.dropcol -f table=zcta510_2012 column=INTPTLON10; \
	db.dropcol -f table=zcta510_2012 column=ALAND10; \
	db.dropcol -f table=zcta510_2012 column=AWATER10; \
	db.dropcol -f table=zcta510_2012 column=FUNCSTAT10; \
	db.dropcol -f table=zcta510_2012 column=MTFCC10; \
	db.dropcol -f table=zcta510_2012 column=CLASSFP10; \
	db.dropcol -f table=zcta510_2012 column=GEOID10; \
	v.db.renamecol map=zcta510_2012  column=ZCTA5CE10,zipcode
endif 

else 

ifneq (${MAPSET},zipcode)
  $(error LOCATION ${LOCATION_NAME} and MAPSET ${MAPSET} neq zipcode)
endif

.PHONY:state
state:${vect}/tl_2012_us_state ${vect}/STUSPS_CA

${etc}/tl_2012_us_state.zip:url:=http://www2.census.gov/geo/tiger/TIGER2012/STATE/tl_2012_us_state.zip
${etc}/tl_2012_us_state.zip:
	[[ -d ${etc} ]] || mkdir ${etc};\
	wget -O $@ ${url}; \
	cd $(dir $@); \
	unzip $(notdir $@);

${vect}/tl_2012_us_state:${etc}/tl_2012_us_state.zip
	v.in.ogr dsn=${etc} layer=$(notdir $@) output=$(notdir $@) type=boundary

${vect}/STUSPS_CA:${etc}/tl_2012_us_state.zip
	v.in.ogr dsn=${etc} layer=tl_2012_us_state output=$(notdir $@) type=boundary where="STUSPS='CA'"

${etc}/tl_2012_us_zcta510.zip:url:=http://www2.census.gov/geo/tiger/TIGER2012/ZCTA5/tl_2012_us_zcta510.zip
${etc}/tl_2012_us_zcta510.zip:
	[[ -d ${etc} ]] || mkdir ${etc}
	wget -O $@ ${url} 
	cd $(dir $@)
	unzip $(notdir $@)

.PHONY:.zip
zip:${vect}/tl_2012_zcta510_CA
${vect}/tl_2012_zcta510_CA:${etc}/tl_2012_us_zcta510.zip ${vect}/STUSPS_CA
	eval $$(v.info -g STUSPS_CA); \
	v.in.ogr dsn=${etc} spatial=$$west,$$south,$$east,$$north layer=tl_2012_us_zcta510 output=$(notdir $@)_box type=boundary;
	v.select ainput=$(notdir $@)_box binput=STUSPS_CA output=$(notdir $@) operator=overlap
	g.remove vect=$(notdir $@)_box

endif

