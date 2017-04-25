#! /usr/bin/make -f

prd:=pro.prd.cimis.water.ca.gov

# It is often not necessary to copy the root tar files, as they are mostly
# symbolic links to the ~cimis files, and probably don't change from update 
# to update.
root.files:=/etc/default/cg /etc/rsyncd.conf

.PHONY: prd.root.tar prd.root.local
prd.root.tar:
	sudo tar -cf - ${root.files} |\
	 ssh root@${prd} tar --directory=/ -xvpf -

prd.root.local:
	rsync -a -v /usr/local/ root@${prd}:/usr/local -n

# The CIMIS user on the other hand should be copied over everytime.

cimis.files:=etc bin grass

.PHONY: prd.cimis prd.cimis prd.cimis.tar prd.cimis.crontab

prd.cimis: prd.cimis.tar prd.cimis.crontab

prd.cimis.tar:
	 tar -cf - --exclude=*~ --directory=`echo ~cimis` ${cimis.files} |\
	 ssh cimis@${prd} tar -xvpf -

prd.cimis.gdb:
	rsync ~cimis/gdb cimis@${prd}:. -a -v

prd.cimis.crontab:
	cat crontab | ssh cimis@${prd} crontab -


