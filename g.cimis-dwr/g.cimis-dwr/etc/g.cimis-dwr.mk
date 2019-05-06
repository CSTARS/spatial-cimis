#! /usr/bin/make -f

ifndef zipcode.mk
include zipcode.mk
endif

ifndef png.mk
include png.mk
endif

g.cimis-dwr.mk:=1
