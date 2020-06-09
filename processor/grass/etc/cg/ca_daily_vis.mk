#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

ca-daily-vis.mk:=1

goes-loc:=$(shell . /etc/default/cg; echo $$CG_GOES_LOC)
ca-daily-vis-loc:=$(shell . /etc/default/cg; echo $$CA_DAILY_VIS_LOC)
interval:=$(shell . /etc/default/cg; echo $$CA_DAILY_VIS_INTERVAL)
cg_base:=$(shell . /etc/default/cg; echo $$CG_BASE)

ifneq (${LOCATION_NAME},$(notdir ${ca-daily-vis-loc}))
  $(error LOCATION_NAME neq $(notdir ${ca-daily-vis-loc}))
endif

#date:=$(shell date --date='today' +%Y-%m-%d)
TZ:=$(shell date +%Z)
date:=$(shell g.gisenv MAPSET)
now-s:=$(shell date --date='now - 1 hour' +%s)
hrs:=$(shell cg.daylight.intervals --noexists delim=' ' --filename=%hh%mm --interval=${interval} sretr=sretr ssetr=ssetr --date=${date})

# Get the UTC version of the file.
# Get current time compares

before:=$(shell for h in ${hrs}; do ms=$$(date --date="$$(date --date="${date} $$h")" +%s); if [[ ${now-s} -gt $$ms ]]; then echo " $$h"; fi; done )
VIP:=${cg_base}/VIP

.PHONY: ca-daily-vis
ca-daily-vis::

define onehour
ca-daily-vis:: ${ca-daily-vis-loc}/${date}/cellhd/vis$1

${ca-daily-vis-loc}/${date}/cellhd/vis$1:${goes-loc}/$2/cellhd/ch1
	@if [[ -f ${goes-loc}/$2/cellhd/ch1 ]]; then \
r.proj input=ch1 mapset=$2 location=$(notdir ${goes-loc}) output=temp 2>/dev/null > /dev/null;\
if [[ $$$$? == 0 ]]; then \
  r.mapcalc vis$1=0.585454025*temp-16.9781625;\
fi;\
  g.mremove --q -f rast=temp; \
else\
   echo $2 or ch1@$2 not found;\
fi;

# Two g.mapsets because of a bug in g.mapset
${goes-loc}/$2/cellhd/ch1:${VIP}/$3
	@ if [[ -f ${VIP}/$3 ]]; then \
	g.mapset -c location=$(notdir ${goes-loc}) mapset=$2 || g.mapset location=$(notdir ${goes-loc}) mapset=$2; \
	if (g.proj -f -j | grep -q "`gvar_inspector --proj --vip ${VIP}/$3`"); then \
	  r.in.gvar -V filename=${VIP}/$3; \
	  g.mapset location=$(notdir ${ca-daily-vis-loc}) mapset=${date}; \
	else \
	  cg.pushover message="$3 Does not match g.proj"; \
	  echo "$3 does not match g.proj";\
	fi;\
else \
  echo $3 not found; \
fi;

${VIP}/$3:
	@rsync -q rsync://goes-w.casil.ucdavis.edu/vip/$3 ${VIP} || true

endef

# define add_one 
# ca-daily-vis::${ca-daily-vis-loc}/${date}/cellhd/vis$1

# ${ca-daily-vis-loc}/${date}/cellhd/vis$1:
# 	@if [[ -f ${goes-loc}/$2/cellhd/ch1 ]]; then \
# r.proj input=ch1 mapset=$2 location=$(notdir ${goes-loc}) output=temp 2>/dev/null > /dev/null;\
# if [[ $$$$? == 0 ]]; then \
#   r.mapcalc vis$1=0.585454025*temp-16.9781625;\
# fi;\
#   g.mremove --q -f rast=temp;\
# else\
#    echo $2 or ch1@$2 not found;\
# fi;
# endef

# hr-rast:=$(patsubst %,${ca-daily-vis-loc}/${date}/cellhd/vis%,${before})

.PHONY: info

info::
	@echo ca-daily-vis
	@echo "Copy Dayight Visible GOES data into CIMIS daily summary"
	@echo "date:${date} (${now-s})"
	@echo "daylight-hours:${hrs}"
	@echo "before:${before}"

$(foreach i,${before},$(eval $(call onehour,$i,$(shell date --date='${date} $i ${TZ}' --utc +%Y-%m-%dT%H%M),$(shell date --date='${date} $i ${TZ}'  -u +'%m%d%H%M\ GOES-15\ Imager\ Complete\ %a\ %d-%b-%Y\ %H%M.VIP'))))





