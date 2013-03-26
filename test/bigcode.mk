#! /usr/bin/make -f 

old:=goes.casil.ucdavis.edu
new:=cimis.casil.ucdavis.edu

start:=$(shell date --date='today-3 days' --iso)
stop:=$(shell date --date='today-1 days' --iso)

zipcodes:=94606,94701,94507,94702,94703,94704,94705,94708,94709,94546,94552,94525,94530,94506,94526,94608,94541,94542,94547,94706,94707,94549,94601,94611,94603,94612,94618,94619,94621,94563,94602,94610,94564,94523,94572,94577,94578,94579,94580,94583,94595,94596,94598,94518,94519,94520,94587,94556,94501,94607,94502,94605,94609,94710,97801,94802,94803,94804,94805,94806,94807,94850

.PHONY: bigcode

bigcode: ${old}.bigcode.xml ${new}.bigcode.xml
	cat  ${old}.bigcode.xml | xmlstarlet sel -t -v '//data/DataPoint/@zipcode|//data/DataPoint/et0' >  ${old}.bigcode.txt
	cat  ${new}.bigcode.xml | xmlstarlet sel -t -v '//data/DataPoint/@zipcode|//data/DataPoint/et0' >  ${new}.bigcode.txt
	diff -w -u ${old}.bigcode.txt ${new}.bigcode.txt

${old}.bigcode.xml:
	time curl 'http://${old}/wms/wms.cgi?TIME=${start}:${stop}&VERSION=1.1&REQUEST=GetFeatureInfo&ZIPCODE=${zipcodes}' >  ${old}.bigcode.xml 

${new}.bigcode.xml:
	time curl 'http://${new}/wms/wms.cgi?TIME=${start}:${stop}&VERSION=1.1&REQUEST=GetFeatureInfo&ZIPCODE=${zipcodes}' > ${new}.bigcode.xml


