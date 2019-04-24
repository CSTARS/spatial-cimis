#!/usr/bin/make -f 

#user:=${USER}
user:=$(shell whoami)
pushto:=CA/
ca:=$(wildcard ~/CA/*)

push:
	rsync -avz -e "ssh -i ~/.ssh/rsync" ${ca} ${user}@cimis-goes-r.cstars.ucdavis.edu:${pushto}
