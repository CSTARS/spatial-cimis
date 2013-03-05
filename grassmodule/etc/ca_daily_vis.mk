#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

ca-daily-vis.mk:=1

goes-loc:=$(shell . /etc/default/cg; echo $$CG_GOES_LOC)
ca-daily-vis-loc:=$(shell . /etc/default/cg; echo $$CA_DAILY_VIS_LOC)
interval:=$(shell . /etc/default/cg; echo $$CA_DAILY_VIS_INTERVAL)

ifneq (${LOCATION_NAME},$(notdir ${ca-daily-vis-loc}))
  $(error LOCATION_NAME neq $(notdir ${ca-daily-vis-loc}))
endif

#date:=$(shell date --date='today' +%Y-%m-%d)
date:=$(shell g.gisenv MAPSET)
#nowz:=$(shell date --utc +%Y-%m-%dT%H%M)
now-s:=$(shell date +%s)
hrs:=$(shell cg.daylight.intervals --noexists delim=' ' --filename=%hh%mm --interval=${interval} sretr=sretr ssetr=ssetr --date=${date})

${ca-daily-vis-loc}/cellhd/sretr:
	g.mapset -c ${date}
	r.solpos date=${date} sretr=sretr ssetr=ssetr ssha=ssha;

# Get the UTC version of the file.
# Get current time compares

before:=$(shell for h in ${hrs}; do ms=$$(date --date="$$(date --date="${date} $$h")" +%s); if [[ ${now-s} -gt $$ms ]]; then echo " $$h"; fi; done )

test:=$(shell for h in ${hrs}; do ms=$$(date --date="$$(date --date="${date} $$h")" +%s); if [[ ${now-s} -ge $$ms ]]; then echo " $${h}:$$(date --date="$$(date --date="${date} $$h")" --utc +%Y-%m-%dT%H%M)"; fi;done )

.PHONY: ca-daily-vis
ca-daily-vis::

define add_one 
ca-daily-vis::${ca-daily-vis-loc}/${date}/cellhd/vis$1

#${ca-daily-vis-loc}/${date}/cellhd/vis$1:${goes-loc}/$2/cellhd/ch1
${ca-daily-vis-loc}/${date}/cellhd/vis$1:
	@if [[ -f ${goes-loc}/$2/cellhd/ch1 ]]; then \
r.proj input=ch1 mapset=$2 location=$(notdir ${goes-loc}) output=temp 2>/dev/null > /dev/null;\
if [[ $$$$? == 0 ]]; then \
  r.mapcalc vis$1=0.585454025*temp-16.9781625;\
fi;\
  g.mremove --q -f rast=temp;\
else\
   echo $2 or ch1@$2 not found;\
fi;
endef

$(foreach t,${test},$(eval $(call add_one,$(firstword $(subst :, ,$t)),$(lastword $(subst :, ,$t)))))

hr-rast:=$(patsubst %,${ca-daily-vis-loc}/${date}/cellhd/vis%,${before})


.PHONY: info

info::
	@echo ca-daily-vis
	@echo "Copy Dayight Visible GOES data into CIMIS daily summary"
	@echo "date:${date} (${now-s})"
	@echo "daylight-hours:${hrs}"
	@echo "before:${before}"
	@echo "test:${test}"
	@echo "hr-rast:${hr-rast}"

get:${hr-rast}

#${hr-rast}:${ca-daily-vis-loc}/${date}/cellhd/%:
#	h=$${$*#vis*}; \
#m=$$(date --date="$$(date --date="${date} $$h")" --utc +%Y-%m-%dT%H%M);\
#if [[ -n ${goes-loc}/$$m/cellhd/ch1 ]]; then \
#     r.proj input=ch1 mapset=$$m location=$(notdir ${goes-loc}) output=temp 2>/dev/null > /dev/null;\
#     r.mapcalc $*=0.585454025*temp-16.9781625;\
#     g.remove temp;\
#else\
#   echo $$m or ch1@$$m not found;\
#fi;


