#! /usr/bin/make -f

solar_functions.mk:=1

# Functions that get time from B2 filename
f_time=$(patsubst %PST-B2,%,$(notdir $1))

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


######################################################
#
# Daily Targets
#
######################################################

define mapset_targets

$(eval etc:=${GISDBASE}/${solar.loc}/$1/etc)
$(eval solrast:=${GISDBASE}/${solar.loc}/$1/cellhd)

$(eval linkeT:=linkeT_$(shell cut -b 5-6 <<<"$1")$(word $(shell cut -b 7-8 <<<"$1"),${tl_DD})@500m)
$(eval heliosat.$1:=elevin=Z@500m linkein=${linkeT} latitude=latitude@500m ssha=ssha)

.PHONY:clean-cloud_window cloud_window clean-tmp clean

cloud_window::${etc}/cloud_window

clean-cloud_window::
	@rm ${etc}/cloud_window

${etc}/cloud_window:
	@$(call g.mapset-c,${solar.loc},$1);\
	[[ -d ${etc} ]] || mkdir ${etc};\
	for i in $$$$(seq -14 0); do \
	  m=$$$$(date --date="$1 + $$$$i days" +%Y%m%d); \
	  if [[ -d ${GISDBASE}/${solar.loc}/$$$$m ]]; then \
	    echo -n "$$$$m,";\
	  fi;\
	done | sed -e "s/,$$$$/\n/" > ${etc}/cloud_window;\
	echo $1/etc/cloud_window

# Sunrise/Sunset parameters are taken from r.solpos

${solrast}/sretr ${solrast}/ssetr ${solrast}/ssha:
	@$(call g.mapset-c,${solar.loc},$1);\
	r.solpos `g.solar_time cmd=day_parms` sretr=sretr ssetr=ssetr ssha=ssha;\
	echo '$1/sretr'

clean-tmp::
	@g.remove -f type=rast pattern=_hel*;\
	g.remove -f type=rast pattern=????PST-G*;\
	g.remove -f type=rast pattern=????PST-K*

clean:: clean-tmp
	@rm -f ${etc}/cloud_window;\
	g.remove -f type=rast name=sretr,ssetr,ssha
endef

# These get run for every timestep (in daytime)
define _everytime
$(eval rast:=${GISDBASE}/${solar.loc}/$3/cellhd)
$(eval etc:=${GISDBASE}/${solar.loc}/$3/etc)

$(eval cloud:=$(call fn_cloud,$1))
$(eval clear_sky:=$(call fn_clear_sky,$1))
$(eval p:=$(patsubst %-B2,%-P,$1))

clean-i-tmp::
	@$(call g.mapset,${solar.loc},$3);\
	g.remove -f type=rast pattern=_hel_*$(patsubst %PST-B2,%,$1)

clean:: clean-tmp
	@$(call g.mapset,${solar.loc},$3);\
	rm -f ${etc}/max/$1;\
	g.remove -f type=rast name=${clear_sky},${cloud_sky},${p},${cloud}

${rast}/${clear_sky}: ${rast}/$1 ${rast}/ssha
	@$(call g.mapset,${solar.loc},$3);\
	r.heliosat -i `g.solar_time cmd=day_parms` `hhmm=$(call f_time,$1); echo "hour=$$$${hhmm%??} minute=$$$${hhmm#??}"` ${heliosat.$3};\
	g.rename --quiet raster=_hel_Gci$(patsubst %PST-B2,%,$1),${clear_sky};\
	echo -n "${clear_sky} "

${etc}/max/$1: ${rast}/$1
	@$(call g.mapset,${solar.loc},$3);\
	[[ -d ${etc}/max ]] || mkdir -p ${etc}/max;\
	(r.neighbors --overwrite input=${1} output=_maxcalc size=5 method=average; \
	 r.info -r _maxcalc; g.remove -f type=rast name=_maxcalc\
	) 2>/dev/null > ${etc}/max/$1

${rast}/${p}: ${rast}/$1 ${etc}/cloud_window
	@$(call g.mapset,${solar.loc},$3);\
	$(call NOMASK)\
	maps=$$$$(g.list separator=',' type=rast mapset=$$$$(cat ${etc}/cloud_window) pattern=$1 | sed -e "s/^/'/" -e "s/,/','/g" -e "s/$$$$/'/");\
	${calc} expression="'${p}'=min($$$${maps})";\
	echo -n '${p} '

${rast}/${cloud}: ${rast}/${p} ${etc}/max/$1
	@$(call g.mapset,${solar.loc},$3);\
	$(call NOMASK)\
	eval $$$$(cat ${etc}/max/$1);\
	${calc} expression="'${cloud}'=if(($$$$max-'${1}')/($$$$max-'${p}')>0.2,\
	  min(($$$$max-'${1}')/($$$$max-'${p}'),1.09),\
	  min(0.2,(1.667)*(($$$$max-'${1}')/($$$$max-'${p}'))^2+(0.333)*(($$$$max-'${1}')/($$$$max-'${p}'))+0.0667))";\
	echo -n '${cloud} '

endef

define _sunrise
$(eval rast:=${GISDBASE}/${solar.loc}/$3/cellhd)
$(eval cloud_sky:=$(call fn_cloud_sky,$1))
$(eval clear_sky:=$(call fn_clear_sky,$1))
$(eval cloud:=$(call fn_cloud,$1))

solar:: ${rast}/${cloud_sky}
	@echo "sunrise"

clean-i-tmp::
	@$(call g.mapset,${solar.loc},$3);\
	g.remove -f type=rast pattern=_hel_`g.solar_time cmd=sretr`

clean::
	@$(call g.mapset,${solar.loc},$3);\
	g.remove -f type=rast name=sretr-Gi

${rast}/sretr-Gi: ${rast}/ssha
	@$(call g.mapset,${solar.loc},$3);\
	r.heliosat -i `g.solar_time cmd=sretr_parms` ${heliosat.$3};\
	g.rename raster=_hel_Gci`g.solar_time cmd=sretr`,sretr-Gi;\
	echo -n " sretr-Gi"

$(call _everytime,$1,$2,$3)

${rast}/${cloud_sky}: ${rast}/sretr-Gi ${rast}/${cloud} ${rast}/${clear_sky}
	@$(call g.mapset,${solar.loc},$3);\
	${calc} expression="'${cloud_sky}'=('${clear_sky}'-'sretr-Gi')*'${cloud}'";\
	echo -n ' ${cloud_sky}'

endef

define _day
$(eval rast:=${GISDBASE}/${solar.loc}/$3/cellhd)
$(eval clear_sky:=$(call fn_clear_sky,$1))
$(eval cloud:=$(call fn_cloud,$1))
$(eval cloud_sky:=$(call fn_cloud_sky,$1))
$(eval prev_cloud:=$(call fn_cloud,$2))
$(eval prev_cloud_sky:=$(call fn_cloud_sky,$2))
$(eval prev_clear_sky:=$(call fn_clear_sky,$2))

solar:: ${rast}/${cloud_sky}
	@echo " solar"

$(call _everytime,$1,$2,$3)

${rast}/${cloud_sky}: ${rast}/${clear_sky} ${rast}/${cloud} ${rast}/${prev_cloud_sky}
	@$(call g.mapset,${solar.loc},$3);\
	${calc} expression="'${cloud_sky}'=('${clear_sky}'-'${prev_clear_sky}')*('${cloud}'+'${prev_cloud}')/2+'${prev_cloud_sky}'";\
	echo -n ' ${cloud_sky}'

endef

define _sunset
$(eval rast:=${GISDBASE}/${solar.loc}/$3/cellhd)

$(eval prev_cloud:=$(call fn_cloud,$2))
$(eval prev_cloud_sky:=$(call fn_cloud_sky,$2))
$(eval prev_clear_sky:=$(call fn_clear_sky,$2))

solar:: ${rast}/ssetr-G ${rast}/ssetr-Gc ${rast}/ssetr-K
	@echo " sunset"

clean-i-tmp::
	@$(call g.mapset,${solar.loc},$3);\
	g.remove -f type=rast pattern=_hel_*`g.solar_time cmd=ssetr`

clean::
	@$(call g.mapset,${solar.loc},$3);\
	g.remove -f type=rast name=ssetr-Gi,ssetr-G,ssetr-Gc

${rast}/ssetr-Gi:
	@$(call g.mapset,${solar.loc},$3);\
	r.heliosat -i `g.solar_time cmd=ssetr_parms` ${heliosat.$3};\
	g.rename raster=_hel_Gci`g.solar_time cmd=ssetr`,ssetr-Gi;\
	echo -n ' ssetr-Gi';

${rast}/ssetr-G: ${rast}/${prev_cloud} ${rast}/${prev_cloud_sky} ${rast}/ssetr-Gi
	@$(call g.mapset,${solar.loc},$3);\
	${calc} expression="'ssetr-G'=('ssetr-Gi'-'${prev_clear_sky}')*'${prev_cloud}'+'${prev_cloud_sky}'";\
	echo -n ' ssetr-G'

${rast}/ssetr-Gc: ${rast}/ssetr-Gi ${rast}/sretr-Gi
	@$(call g.mapset,${solar.loc},$3);\
	${calc} expression="'ssetr-Gc'='ssetr-Gi'-'sretr-Gi'"

${rast}/ssetr-K: ${rast}/ssetr-Gi ${rast}/ssetr-G
	@$(call g.mapset,${solar.loc},$3);\
	${calc} expression="'ssetr-K'='ssetr-G'/'ssetr-Gc'"

endef

# This loops through all the files, and uses it's time of day
# night,sunrise,day,sunset to run the appropriate set of commands
# g.solar_time selects the one to run, and supplies the prev value as well
define next_solar_calc
$(eval tod:=$(shell g.solar_time cmd=risedayset rast=$1))
$(call _$(firstword ${tod}),$1,$(lastword ${tod}),$2)
endef
