#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

solar.mk:=1

ifneq (${LOCATION_NAME},${solar.loc})
  $(error LOCATION_NAME,${LOCATION_NAME} neq ${goes.loc})
endif

# Check this is a YYYY-MM-DD setup
ifndef DD
$(error MAPSET ${MAPSET} is not YYYYMMDD)
endif

rasters:=$(shell g.list type=rast pattern=????PST-B2)

c_day_parms:=$(shell ./g.cimist day_parms)
c_ssetr_parms=$(shell ./g.cimist ssetr_parms $1)

info::
	@echo solar.mk
	@echo Calculate Solar Parameters
	@echo rast:${rast}
	@echo rasters:${rasters}
#	$(foreach r,${rasters},echo $r:$(shell ./g.cimist risedayset $r);)

f_time=$(patsubst %PST-B2,%,$(notdir $1))
f_hhmm_parms=$(shell hhmm=$(call f_time,$1); echo "hour=$${hhmm%??} minute=$${hhmm\#??}")

## Handy oneline file name functions
fn_cloud=$(patsubst %-B2,%-K,$1)
fn_clear_sky=$(patsubst %-B2,%-Gi,$1)
fn_cloud_sky=$(patsubst %-B2,%-G,$1)

calc:=r.mapcalc --overwrite --quiet

#######################################
# Heliosat Parameters
#######################################
# Linke Turbidity
tl_DD:=01 01 01 01 07 07 07 07 07 07 \
    07 15 15 15 15 15 15 15 21 21 \
    21 21 21 21 28 28 28 28 28 28 28

linkeT:=linkeT_${MM}$(word ${DD},${tl_DD})@500m

heliosat_in:=elevin=Z@500m linkein=${linkeT} latitude=latitude@500m ssha=ssha

######################################################
#
# Daily Targets
#
######################################################
.PHONY:clean-cloud_window cloud_window clean-tmp clean

cloud_window:${etc}/cloud_window
	echo ${etc}/cloud_window

clean-cloud_window:
	rm ${etc}/cloud_window

${etc}/cloud_window:
	[[ -d ${etc} ]] || mkdir ${etc}
	for i in $$(seq -14 0); do \
	  m=$$(date --date="${MAPSET} + $$i days" +%Y%m%d); \
	  if [[ -d ${loc}/$$m ]]; then \
	    echo -n "$$m,";\
	  fi;\
	done | sed -e "s/,$$/\n/" > $@

# Sunrise/Sunset parameters are taken from r.solpos
${rast}/sretr ${rast}/ssetr ${rast}/ssha:
	r.solpos ${c_day_parms} sretr=sretr ssetr=ssetr ssha=ssha

clean-tmp::
	g.remove -f type=rast pattern=_hel*

clean:: clean-tmp
	rm -f ${etc}/cloud_window;\
	g.remove -f type=rast name=sretr,ssetr,ssha

# These get run for every timestep (in daytime)
define _everytime
$(eval cloud:=$(call fn_cloud,$1))
$(eval clear_sky:=$(call fn_clear_sky,$1))
$(eval p:=$(patsubst %-B2,%-P,$1))

clean-i-tmp::
	g.remove -f type=rast pattern=_hel_*$(patsubst %PST-B2,%,$1)

clean:: clean-tmp
	rm -f ${etc}/max/$1;\
	g.remove -f type=rast name=${clear_sky},${cloud_sky},${p},${cloud}

${rast}/${clear_sky}: ${rast}/$1 ${rast}/ssha
	r.heliosat -i ${c_day_parms} $(call f_hhmm_parms,$1) ${heliosat_in};\
	g.rename raster=_hel_Gci$(patsubst %PST-B2,%,$1),${clear_sky}

${etc}/max/$1: ${rast}/$1
	@[[ -d ${etc}/max ]] || mkdir -p ${etc}/max;\
	(r.neighbors --overwrite input=${1} output=_maxcalc size=5 method=average; \
	 r.info -r _maxcalc; g.remove -f type=rast name=_maxcalc\
	) 2>/dev/null > ${etc}/max/$1

${rast}/${p}: ${rast}/$1 ${etc}/cloud_window
	@$(call NOMASK)\
	maps=$$$$(g.list separator=',' type=rast mapset=$$$$(cat ${etc}/cloud_window) pattern=$1 | sed -e "s/^/'/" -e "s/,/','/g" -e "s/$$$$/'/");\
	${calc} expression="'${p}'=min($$$${maps})"

${rast}/${cloud}: ${rast}/${p} ${etc}/max/$1
	@$(call NOMASK)\
	eval $$$$(cat ${etc}/max/$1);\
	${calc} expression="'${cloud}'=if(($$$$max-'${1}')/($$$$max-'${p}')>0.2,\
	  min(($$$$max-'${1}')/($$$$max-'${p}'),1.09),\
	  (1.667)*(($$$$max-'${1}')/($$$$max-'${p}'))^2+(0.333)*(($$$$max-'${1}')/($$$$max-'${p}'))+0.0667)"

endef

define _sunrise
$(info sunrise:$1 <- srter )
$(eval cloud_sky:=$(call fn_cloud_sky,$1))
$(eval clear_sky:=$(call fn_clear_sky,$1))
$(eval cloud:=$(call fn_cloud,$1))

solar:: ${rast}/${cloud_sky}

clean-i-tmp::
	g.remove -f type=rast pattern=_hel_*$(shell ./g.cimist sretr)

clean::
	g.remove -f type=rast name=sretr-Gi

${rast}/sretr-Gi: ${rast}/ssha
	r.heliosat -i $(shell ./g.cimist sretr_parms $1) ${heliosat_in};
	g.rename raster=_hel_Gci$(shell ./g.cimist sretr),sretr-Gi

$(call _everytime,$1)

${rast}/${cloud_sky}: ${rast}/sretr-Gi ${rast}/${cloud} ${rast}/${clear_sky}
	${calc} expression="'${cloud_sky}'=('${clear_sky}'-'sretr-Gi')*'${cloud}'"

endef

define _day
$(info day:$1 <- $2)
$(eval clear_sky:=$(call fn_clear_sky,$1))
$(eval cloud:=$(call fn_cloud,$1))
$(eval cloud_sky:=$(call fn_cloud_sky,$1))
$(eval prev_cloud:=$(call fn_cloud,$2))
$(eval prev_cloud_sky:=$(call fn_cloud_sky,$2))
$(eval prev_clear_sky:=$(call fn_clear_sky,$2))

solar:: ${rast}/${cloud_sky}

$(call _everytime,$1)

${rast}/${cloud_sky}: ${rast}/${clear_sky} ${rast}/${cloud} ${rast}/${prev_cloud_sky}
	${calc} expression="'${cloud_sky}'=('${clear_sky}'-'${prev_clear_sky}')*('${cloud}'+'${prev_cloud}')/2+'${prev_cloud_sky}'"

endef

define _sunset
$(info sunset:ssetr <- $2)

$(eval prev_cloud:=$(call fn_cloud,$2))
$(eval prev_cloud_sky:=$(call fn_cloud_sky,$2))
$(eval prev_clear_sky:=$(call fn_clear_sky,$2))

solar:: ${rast}/ssetr-G ${rast}/ssetr-Gc

clean-i-tmp::
	g.remove -f type=rast pattern=_hel_*$(shell ./g.cimist ssetr)

clean::
	g.remove -f type=rast name=ssetr-Gi,ssetr-G,ssetr-Gc

${rast}/ssetr-Gi:
	@r.heliosat -i $(shell ./g.cimist ssetr_parms $1) ${heliosat_in};\
	g.rename raster=_hel_Gci$(shell ./g.cimist ssetr),ssetr-Gi

${rast}/ssetr-G: ${rast}/${cloud} ${rast}/${cloud_sky} ${rast}/ssetr-Gi
	${calc} expression="'ssetr-G'=('ssetr-Gi'-'${prev_clear_sky}')*'${prev_cloud}'+'${prev_cloud_sky}'"

${rast}/ssetr-Gc: ${rast}/ssetr-Gi ${rast}/sretr-Gi
	${calc} expression="'ssetr-Gc'='ssetr-Gi'-'sretr-Gi'"

endef

#$(info $1:$(firstword ${tod})->$(lastword ${tod}))
define solar
$(eval tod:=$(shell ./g.cimist risedayset $1))
$(call _$(firstword ${tod}),$1,$(lastword ${tod}))
endef

$(foreach f,${rasters},$(eval $(call solar,$f)))
