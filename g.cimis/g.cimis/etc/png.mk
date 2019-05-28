#! /usr/bin/make -f

ifndef configure.mk
include configure.mk
endif

png.mk:=1

# New one will be this
daily_dir:=$(YYYY)/$(MM)/$(DD)
htdocs:=/var/www/cimis17
html:=$(htdocs)/$(daily_dir)

.PHONY: info
info::
	@echo png.mk
	@echo html files to ${html}

html_layers:= Rso Rs K Rnl Tdew ETo Tx Tn U2

html: $(patsubst %,$(html)/%.png,$(html_layers)) $(patsubst %,$(html)/%.asc.gz,$(html_layers)) ${html}/station.csv

clean-html::
	rm -rf $(html)

${html}/station.csv:${etc}/station.csv
	cp $< $@

${etc}/station.csv: ${vect}/et
	[[ -d ${etc} ]] || mkdir -p ${etc}
	cols=`v.info -c et 2>/dev/null | grep day | cut -d'|' -f 2 | tr "\n" ',' | sed -e 's/.$$//'`;\
	echo "x,y,z,station_id,date,$${cols}" > $@ ;\
	v.out.ascii input=et separator=',' precision=2 columns=date,$${cols} >>$@

define png
.PHONY: $(1).png

$(1).png: $(html)/$(1).png $(html)/$(1).asc.gz
$(1).asc.gz: $(html)/$(1).asc.gz

$(html)/$(1).asc.gz: $(rast)/$(1)
	@echo $(1).asc.gz
	@[[ -d $(html) ]] || mkdir -p $(html)
	@r.out.gdal input=$(1) format=AAIGrid nodata=-9999 output=$(html)/$(1).asc &>/dev/null;
	@gzip -f $(html)/$(1).asc;
	@rm $(html)/$(1).asc.aux.xml
	@rm $(html)/$(1).prj

$(html)/$(1).png: $(rast)/$(1)
	@echo $(1).png
	@[[ -d $(html) ]] || mkdir -p $(html);
	@d.mon -r; sleep 1; \
	$(call MASK) \
	GRASS_RENDER_WIDTH=2304 GRASS_RENDER_HEIGHT=2560 \
	d.mon start=png output=${html}/$1.png &> /dev/null; \
	d.frame -e; d.rast $1; \
	d.vect counties@PERMANENT type=boundary color=white fcolor=none; \
	d.legend -s at=7,52,2,8 raster=$1 color=black; \
	if [[ -n "$3" ]]; then \
	 echo '$3' | d.text color=black at=2,2 size=3; \
	fi; \
	echo -e ".B 1\n$2" | d.text at=45,90 color=black size=4; \
	d.mon stop=png &> /dev/null;\
	$(call NOMASK)

endef

# Special for report
$(eval $(call png,nd_max_at_lr5_t10_s0.03,,C))
$(eval $(call png,d_max_at_dme,,C))
$(eval $(call png,d_max_at_ns,,C))
$(eval $(call png,d_max_rh_dme,,%))
$(eval $(call png,d_max_rh_$(tzs),,%))
$(eval $(call png,FAO_Rso,CIMIS Radiation,W/m^2))
$(foreach p,00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24,$(eval $(call png,vis$(p)00,Visible GOES-$(p)00,count)))
$(foreach p,00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24,$(eval $(call png,p$(p)00,Albedo GOES-$(p)00,count)))
$(foreach p,00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24,$(eval $(call png,k$(p)00,Clear Sky-$(p)00,count)))

$(eval $(call png,Tn,Tn, C))
$(eval $(call png,Tx,Tx, C))
$(eval $(call png,Tdew,Tdew, C))
$(eval $(call png,RHx,RHx, C))
$(eval $(call png,U2,Wind Speed, m/s))

$(eval $(call png,Rs,Rs View,MJ/m^2 day))
$(eval $(call png,Rso,Clear Sky Radiation,MJ/m^2 day))
$(eval $(call png,K,Clear Sky Parameter, ))
$(eval $(call png,ETo,ETO View, mm))
$(eval $(call png,Rnl,Long wave Radiation, MJ/m^2))

$(eval $(call png,mc_ETo_avg,ETO Confidence Avg.,mm))
$(eval $(call png,mc_ETo_err_3,ETO Confidence Std.,mm))
