#! /usr/bin/make -f 

old:=goes.casil.ucdavis.edu
new:=cimis.casil.ucdavis.edu

start:=$(shell date --date='today-3 days' --iso)
stop:=$(shell date --date='today-1 days' --iso)

zipcodes:=93624
xs:=-121.74
ys:=50.64

.PHONY: zipcode point test

zipcode:
	time curl 'http://${old}/wms/wms.cgi?TIME=${start}:${stop}&VERSION=1.1&REQUEST=GetFeatureInfo&ZIPCODE=${zipcodes}' | xmlstarlet sel -t -v '//data/DataPoint/@zipcode|//data/DataPoint/et0' >  old.zipcode.xml
	time curl 'http://${new}/wms/wms.cgi?TIME=${start}:${stop}&VERSION=1.1&REQUEST=GetFeatureInfo&ZIPCODE=${zipcodes}' | xmlstarlet sel -t -v '//data/DataPoint/@zipcode|//data/DataPoint/et0' > new.zipcode.xml
	diff -w -u old.zipcode.xml new.zipcode.xml 
point:
	time curl 'http://${old}/wms/wms.cgi?TIME=${start}:${stop}&VERSION=1.1&REQUEST=GetFeatureInfo&SRID=4269&BBOX=0,0,180,90&HEIGHT=90&WIDTH=180&X=${xs}&Y=${ys}' | xmlstarlet sel -t -v '//data/DataPoint/@lat|//data/DataPoint/@lon|//data/DataPoint/ETo|//data/DataPoint/Rs' > old.point.xml
	time curl 'http://${new}/wms/wms.cgi?TIME=${start}:${stop}&VERSION=1.1&REQUEST=GetFeatureInfo&SRID=4269&BBOX=0,0,180,90&HEIGHT=90&WIDTH=180&X=${xs}&Y=${ys}' | xmlstarlet sel -t -v '//data/DataPoint/@lat|//data/DataPoint/@lon|//data/DataPoint/ETo|//data/DataPoint/Rs' > new.point.xml
	diff -w -u old.point.xml new.point.xml
