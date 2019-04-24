#! /usr/bin/make -f 

ifndef configure.mk
include configure.mk
endif

averages.mk:=1

# Allow the inclusion of xxxx's in the date.
YYYY:=$(shell echo $(MAPSET) | perl -n -e '/^([2x][0x][x\d]{2})(-([01]\d))?(-([0123]\d))?$$/ and print $$1;')
MM:=$(shell echo $(MAPSET) | perl -n -e '/^([2x][0x][x\d]{2})(-([01]\d))(-([0123]\d))?$$/ and print $$3;')
DD:=$(shell echo $(MAPSET) | perl -n -e '/^([2x][0x][x\d]{2})(-([01]\d))(-([0123]\d))?$$/ and print $$5;')

layers:= Rso Rs K Rnl Tdew ETo Tx Tn U2

###############################################
# Use mapset to determine month, and make 
# averages 
##############################################
.PHONY:clean averages

define YYYY-MM

averages::$(rast)/$(1)

clean::
	g.remove rast=$(1)

.PHONY: $(1)
$(1): $(rast)/$(1)

$(rast)/$(1): 
	for d in `seq -f "%02g" 01 31`; \
	  do eval `g.findfile element=cellhd mapset=$(MAPSET)-$$$$d file=$(1)`; \
	  if [[ $$$$fullname != '' ]]; then \
	    let n++; \
	    if [[ -z $$$$sum ]]; then \
	     sum="$$$$fullname"; \
	     else \
	     sum="$$$$sum,$$$$fullname"; \
	   fi; \
	  fi; \
	done; \
	echo sum is $$$$sum; \
	r.series output=${1} input=$$$$sum method=average; \
	r.colors map=$(1) rast=$(1)@default_colors >/dev/null
endef

ifndef DD
ifneq ($(YYYY),xxxx)
 ifdef MM
   $(foreach r,${layers},$(eval $(call YYYY-MM,$r)))
 endif
endif
endif

###############################################
# These methods are supposed to calculate 
# averages of monthly averages, over multiple years
##############################################
.PHONY:clean averages

define xxxx-MM

averages::$(rast)/$(1)
clean::
	g.remove rast=$(1)

.PHONY: $(1)
$(1): $(rast)/$(1)

$(rast)/$(1):
	for d in `g.mapsets fs=newline -l | grep '^2...-${MM}$$$$'`; \
	  do eval `g.findfile element=cellhd mapset=$$$$d file=$(1)`; \
	  if [[ $$$$fullname != '' ]]; then \
	    let n++; \
	    if [[ -z $$$$sum ]]; then \
	     sum="$$$$fullname"; \
	     else \
	     sum="$$$$sum,$$$$fullname"; \
	   fi; \
	  fi; \
	done; \
	echo sum is $$$$sum; \
	r.series output=${1} input=$$$$sum method=average; \
	r.mapcalc q${1}='int(${1}*10)'; \
	r.colors map=$(1) rast=$(1)@default_colors >/dev/null
endef

define xxxx-MM-DD

averages::$(rast)/$(1)
clean::
	g.remove rast=$(1)

.PHONY: $(1)
$(1): $(rast)/$(1)

$(rast)/$(1):
	for d in `seq 2003 2010`; \
	  do eval `g.findfile element=cellhd mapset=$$$$d-$(MM)-$(DD) file=$(1)`; \
	  if [[ $$$$fullname != '' ]]; then \
	    let n++; \
	    if [[ -z $$$$sum ]]; then \
	     sum="\"$$$$fullname\""; \
	     else \
	     sum="$$$$sum+\"$$$$fullname\""; \
	   fi; \
	  fi; \
	done; \
	echo sum is $$$$sum; \
	r.mapcalc $(1)="($$$$sum)/$$$$n"; \
	r.colors map=$(1) rast=$(1)@default_colors >/dev/null
endef

ifeq ($(YYYY),xxxx)
ifdef MM
ifeq ($(DD),)
 $(warning Monthly Averages)
 $(foreach r,$(layers),$(eval $(call xxxx-MM,$(r))))
else
 $(warning Daily Averages)
 $(foreach r,${layers},$(eval $(call xxxx-MM-DD,$(r))))
endif
else
 $(foreach r,$(layers),$(eval $(call xxxx,$(r))))
endif
endif

###############################################################################
# This section is for calculating html output
###############################################################################
.PHONY: html

html:: $(patsubst %,$(html)/%.png,$(html_layers)) $(patsubst %,$(html)/%.asc.gz,$(html_layers))

clean-html:
	rm -rf $(html)

define PNG
.PHONY: $(1).png

$(1).png: $(html)/$(1).png $(html)/$(1).asc.gz
$(1).asc.gz: $(html)/$(1).asc.gz

$(html)/$(1).asc.gz: $(rast)/$(1)
	@echo $(1).asc.gz
	@[[ -d $(html) ]] || mkdir -p $(html)
	@r.out.arc input=$(1) output=$(html)/$(1).asc &>/dev/null;
	@gzip -f $(html)/$(1).asc;

$(html)/$(1).png: $(rast)/$(1)
	@echo $(1).png
	@[[ -d $(html) ]] || mkdir -p $(html)
	@. $(shlibdir)/mapping_functions.shlib; \
	d_png $(html)/$(1).png $(1) '$(2)' '$(3)' '$(4)';
endef

# Special for report
$(eval $(call PNG,Tn,Tn, C))
$(eval $(call PNG,Tx,Tx, C))
$(eval $(call PNG,Tdew,Tdew, C))
$(eval $(call PNG,U2,Wind Speed, m/s))
$(eval $(call PNG,Rs,Rs View,MJ/m^2 day))
$(eval $(call PNG,Rso,Clear Sky Radiation,MJ/m^2 day))
$(eval $(call PNG,K,Clear Sky Parameter, ))
$(eval $(call PNG,et0,ET0 View, mm))
$(eval $(call PNG,mc_et0_err_3,ET0 Error, mm))
$(eval $(call PNG,mc_et0_avg,MC ET0, mm))
$(eval $(call PNG,Rnl,Long wave Radiation, MJ/m^2))

