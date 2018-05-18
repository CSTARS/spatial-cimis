#! /usr/bin/make -f 

base:=/grb/raw
#base:=/home/quinn/raw
iso:=$(shell echo $$(date --date='now -1 hours' --iso=minutes))
raw_conus:=$(wildcard ${base}/conus/satimage*-B2.pgm)
raw_full:=$(wildcard ${base}/fulldisk/satimage*-B2.pgm)

#conus:=$(shell find /grb/raw/conus/ -newermt $$(date --date='now -1 hours' --iso=seconds) -name \*-B2.pgm)

define iso-fn =
$(shell date --date="$$(date --date=@$$(stat --format='%Z' $1)) - 7 hours" +%Y%m%dT%H%MPST)
endef

define iso-date =
$(shell date --date="@$$(stat --format='%Z' $1)" --iso=seconds)
endef

define iso-rule =
CA::CA/$(call iso-fn,$1).pgm
CA/$(call iso-fn,$1).pgm:$1
	convert -crop ${crop.ca} $$< $$@
	touch --date='$(call iso-date,$1) + 1 minute' $$@
endef

define iso-frule =
fCA::fCA/$(call iso-fn,$1).pgm
fCA/$(call iso-fn,$1).pgm:$1
	convert -crop ${crop.ca} $$< $$@
	touch --date='$(call iso-date,$1) + 1 minute' $$@
endef

ca:=$(patsubst ${base}/conus/satimage-%,CA/%,${raw_conus})
conus:=$(patsubst ${base}/conus/satimage-%,conus/%,${raw_conus})

test:=raw/conus/satimage-T228AD691-B2.pgm

crop.ca:=2460x1912!+3121+2925
crop.conus:=10000x6000!+3608+1688

$(foreach r,${raw_conus},$(eval $(call iso-rule,$r)))
$(foreach r,${raw_full},$(eval $(call iso-frule,$r)))


INFO:
	@echo ${conus}
	@echo ${ca}

conus:${conus}

${conus}:conus/%:${base}/conus/satimage-%
	convert -crop ${crop.conus} $< $@

ca:${ca}

${ca}:CA/%:${base}/conus/satimage-%
	convert -crop ${crop.ca} $< $@
