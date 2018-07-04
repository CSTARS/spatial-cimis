#! /usr/bin/make -f 

ifndef configure.mk
include configure.mk
endif

PNG.mk:=1

.PHONY: info
info::
	@echo png.mk

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
	@[[ -d $(html) ]] || mkdir -p $(html);
	@d.mon -r; sleep 1; \
	$(call MASK) \
	GRASS_WIDTH=500 GRASS_HEIGHT=550 \
	GRASS_TRUECOLOR=TRUE GRASS_BACKGROUND_COLOR=FFFFFF \
	GRASS_PNGFILE=${html}/$1.png d.mon start=PNG &> /dev/null; \
	d.frame -e; d.rast $1; \
	d.vect counties@PERMANENT type=boundary color=white fcolor=none; \
	d.legend -s at=7,52,2,8 map=$1 color=black; \
	if [[ -n "$3" ]]; then \
	 echo '$3' | d.text color=black at=2,2 size=3; \
	fi; \
	echo -e ".B 1\n$2" | d.text at=45,90 color=black size=4; \
	d.mon stop=PNG &> /dev/null;\
	$(call NOMASK)
endef
