#!/usr/bin/make -f 

ca:=$(wildcard /home/quinn/CA/*)

push:
	rsync -avz -e "ssh -i ~/.ssh/rsync" ${ca} quinn@cimis-goes-r.cstars.ucdavis.edu:CA/
