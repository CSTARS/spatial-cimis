# Spatial CIMIS

For 2018 Spatial CIMIS will begin processing the next generation GOES-16/17
data.  This will require new infrastructure (new dish and servers) and a slightly
modified spatial CIMIS toolset to process the new spatial data.


# Development Machines

These instructions are for setting up the spatial CIMIS program for either
Ubuntu (UCD) or Red Hat / Fedora (DWR) based servers.

Spatial CIMIS is run primarily with the GRASS GIS program.  However,
there are some additional steps that need to take place. These vary
between development and test machines

## Software installation

The development machine needs to include packages that allow both the
operation of the software, but also the compilation of the Spatial
GOES code.  Therefore additional development packages need to be
installed on these systems.  Use the following commands to install the
required packages.

### Red Hat / Fedora
``` bash
sudo dnf update
sudo dnf install sqlite rsync wget curl perl cronie daemonize \
    perl-JSON perl-Date-Manip perl-TimeDate perl-Test-Pod \
    perl-SOAP-Lite perl-XML-Simple
sudo dnf install geos geos-devel grass grass-devel gcc
```

### Ubuntu
``` bash
sudo apt update;sudo apt upgrade
sudo apt install sqlite rsync wget curl perl cron daemon \
    libjson-pp-perl libdate-manip-perl libdatetime-perl libtest-pod-perl \
    libsoap-lite-perl libxml-simple-perl
sudo apt install libgeos-3.5.0 libgeos-dev grass grass-dev gcc
```

## Install and Configure Incron

## Install GRASS7

## Install Spatial CIMIS

`sudo su - cimis`
`git clone -b GOES-16-17 https://github.com/CSTARS/spatial-cimis`
`ln –sf spatial-cimis/gdb`
`grass -text ~/gdb/cimis/PERMANENT`

The cimis user will need the ET APP key.   `~cimis/.grass7/rc` should contain:

```
MAPSET: 500m 
ET_APPKEY: {your app key} 
GISDBASE: /home/cimis/gdb 
LOCATION_NAME: cimis 
GUI: text 
```
Verify ET_APPKEY by running GRASS and checking with the `v.in.et -?` command:
`GRASS 7.4.0 (cimis):~ > v.in.et -?`
`GRASS 7.4.0 (cimis):~ > g.gisenv`

### GrassModules

### Grass database, ~/gdb

# GOESBOX Configuration (an Open Suse Leap 42.3 or newer server)

## Incron

Incron setup for grb-box.cstars.ucdavis.edu or DWR receiver

[Download RPM package](https://software.opensuse.org/package/incron?search_term=incron) for OpenSuse Leap 42.3 and install

`rpm -i /root/incron-0.5.10-2.1.x86_64.rpm`

Register startup script:  `insserv incron` 

More details at http://inotify.aiken.cz/?section=incron&page=download&lang=en

Create the cimis user and CA subset directory 
```
useradd –m –c “Spatial CIMIS” cimis
mkdir /grb/raw/CA ; chown cimis /grb/raw/CA
cd ; ln -sf /grb/raw/CA
```
Subset data should reside on the largest storage array 

Clone repo 

```
cd 
git clone -b GOES-16-17 https://github.com/CSTARS/spatial-cimis
```

Pre-setup incron 
```
echo cimis >> /etc/incron.allow 
$grb-box=$(find cd /home/cimis/spatial-cimis/grb-box |grep –v README) 
sudo cp -v $grb-box /usr/local/binj/grb-box 
sudo chmod 644 *.mk 
sudo chmod 754 goestcl 
chgrp cimis goesctl *.mk 

goes-ctl 
  make --silent --directory=/usr/local/grb-box -f goesctl.mk "$@" 

convert.mk 
  base:=/home/cimis 

push.mk 
  ca:=$(wildcard /home/cimis/CA/*) 
  … 
  rsync -avz -e "ssh -i ~/.ssh/rsync" ${ca} cimis@cimis-goes-r.cstars.ucdavis.edu:CA 
```

On the grb-box create a passwordless ssh key pair for the rsync exchange and add public key to `cimis@GOESBOX/.ssh/authorized_keys`.  Pre-pend string `from="IP of GRB Box receiver"` to limit access only from the GRB-BOX. 

```
ssh-keygen -t rsa -b 4096 -C "cimis@grb-box.cstars.ucdavis.edu"

incrontab –e 
/grb/raw/fulldisk IN_CREATE /usr/local/grb-box/goesctl raw=$@/$# CA 
/home/cimis/CA IN_CREATE /usr/local/grb-box/goesctl ca=$@/$# push 
```

Initially connect with the rsync ssh connection with the key pairs to accept the connection.  The incrontab session should now be pushing CA cropped band 2 images to the cimis server. 

Keep the last 6 months of CA subsetted data on the grb-box 

```crontab -e 
4 4 * * * find /home/cimis/CA/ -mtime +180  -name \*.pgm | xargs rm 
```

# Final Configuration

## Pushing GOES16 Data

### UCD GOES16 data replaces DWR GOES15 data
As of October 23rd 2018 the production DWR and UCD Spatial CIMIS processors no longer processes GOES15 data from their respective on site dishes and receivers.  Instead they pull daily GOES16 CIMIS data products from the UCD GOES16 processor and use existing processes to continue to provide raster outputs, Arc/Info ASCII Grid output as well as ETo data for the webAPI.

Each GOES15 processor run scripts as the `cimis` user to accomplish this.

3:15am `/home/cimis/bin/cg.tunnel` 

Pulls daily GOES16 grass maps to `/home/cimis/gdb/cimis`

3:30am `/home/cimis/bin/cg.grass.script /home/cimis/bin/cg.daily.output`

The `cg.daily.output` grass script runs a modified version of the raster output grass makefile `png-special` which creates the daily raster images and zipcodes.

Scripts available in this [repo](https://github.com/CSTARS/spatial-cimis/tree/GOES-16-17/bin).

