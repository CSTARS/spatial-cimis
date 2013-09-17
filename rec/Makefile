#! /usr/bin/make -f

rec:=rec.prd.cimis.water.ca.gov

rec.cimis.authorized_keys:
	rsync cg.check_key cimis@${rec}:.ssh/; \
	ssh cimis@${rec} -c 'cd .ssh; cat cg.check_key  >> authorized_keys'


