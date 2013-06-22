#! /usr/bin/make -f

prd:=arc.prd.cimis.water.ca.gov

# It is often not necessary to copy the root tar files, as they are mostly
# symbolic links to the ~cimis files.
root.files:=/etc/monit.d/gvar_reader /etc/init.d/gvar_reader \
	/etc/default/cg /etc/default/gvar_reader

.PHONY: prd.root.tar prd.root.local
prd.root.tar:
	sudo tar -cf - ${root.files} |\
	 ssh root@${prd} tar --directory=/ -xvpf -

prd.root.local:
	rsync -a -v /usr/local/ root@${prd}:/usr/local -n

# The CIMIS user on the other hand should be copied over probably.

cimis.files:=etc bin grass

.PHONY: prd.cimis prd.cimis prd.cimis.tar prd.cimis.crontab

prd.cimis: prd.cimis.tar prd.cimis.crontab

prd.cimis.tar:
	 tar -cf - --exclude=*~ --directory=`echo ~cimis` ${cimis.files} |\
	 ssh cimis@${prd} tar -xvpf -

# rsync GOES15 --exclude=2013-06-0* --exclude=2013-06-1[0123456]*  cimis@arc.prd.cimis.water.ca.gov:gdb -a -v
prd.cimis.gdb:
	rsync ~cimis/gdb --exclude=GOES15 --exclude=wga cimis@arc.prd.cimis.water.ca.gov:. -a -v

prd.cimis.crontab:
	cat crontab | ssh cimis@${prd} crontab -


