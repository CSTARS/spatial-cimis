# Spatial CIMIS

For 2018 Spatial CIMIS will begin processing the next generation GOES-16/17
data.  This will require new infrastructure (new dish and servers) and a slightly
modified spatial CIMIS toolset to process the new spatial data.


# Development CIMIS Processor

Follow these instructions to setup the spatial CIMIS program on the GOES processing server.

Spatial CIMIS is run primarily with the GRASS GIS program.  Additional steps 
are required to acquire the raw GOES data and SHOULD BE RUN AS THE CIMIS USER.


## Install GRASS7

## Install Spatial CIMIS

Download the Spatial CIMIS GRASS initial database and processing scripts.
```
sudo su - cimis
git clone -b GOES-16-17 https://github.com/CSTARS/spatial-cimis
ln –sf spatial-cimis/gdb
grass -text ~/gdb/cimis/PERMANENT
```

### Configuration

There are a number of configuration parameters that are required for
operation.  The `cimis` user needs to identify the GOES receiver, the
ET_APP Application key, and the ET_URL to use to request the data.

`~cimis/.grass7/rc` should look something like this:

```
MAPSET: 500m 
ET_APPKEY: {your app key} 
GISDBASE: /home/cimis/gdb 
LOCATION_NAME: cimis 
GUI: text 
```

You can set these parameters, using the g.gisenv parameter.  You only
have to do this one time.

```bash
g.gisenv set=GOES=17
g.gisenv set=ET_URL=https://et.water.ca.gov/api
g.gisenv set=ET_APPKEY=${secret_key}
```

Verify ET_URL and ET_APPKEY both work by running GRASS and checking
with the `v.in.et -?` command.  [Install GRASS modules for this
work](https://github.com/CSTARS/spatial-cimis/tree/GOES-16-17#install-grass-modules)

```bash
GRASS 7.4.0 (cimis):~ > v.in.et -?
GRASS 7.4.0 (cimis):~ > g.gisenv
```

### Install and Configure Incron

With incron installed ensure the cimis user can add to its incrontab file:

`echo cimis >> /etc/incron.allow`

### Setup GOES.mk

The following incron job copies cloud cover data into the Grass DB (GOES16 or GOES17). 

Edit the goes.mk file and update the following line to ensure it points to the correct
home directory.
```
sudo su – cimis 
vi ~/spatial-cimis/g.cimis/etc/goes.mk 
```

Make sure this line looks like this:
```
files:=$(wildcard /home/cimis/CA/*.pgm) 
```
Add the following incronab entry which will import into GRASS the recently acquired raw data from the receiver.
```
incrontab –e  
```
```
/home/cimis/CA IN_MOVED_TO \ 
  grass /home/cimis/gdb/goes16/cimis \ 
  --exec /home/cimis/spatial-cimis/g.cimis/etc/goes.mk \ 
  --directory=/home/cimis/spatial-cimis/g.cimis/etc files=$@/$# import solar 
```

### Install GRASS modules

Download, compile r.solpos and r.heliosat using `g.extension`.  
This process adds it to the local addons in ~/.grass7/addons. 

```
sudu su – cimis ; cd src 
git clone https://github.com/CSTARS/r.solpos 
cd gdb
grass cimis/cimis 
cd ~src/r.solpos 
g.extension r.solpos url=/home/cimis/src/r.solpos 
r.solpos --help 
g.extension r.heliosat url=/home/cimis/spatial-cimis/r.heliosat 
r.heliosat 
g.extension extension=v.in.et url=/home/cimis/spatial-cimis/v.in.et 
v.in.et -? 
```

### Solar Calculation

The clear sky solar calculation uses the cloud cover data from the GOES16/17 
Grass DB to calculate the actual solar net radiation.  Data is collected every 15 minutes with a daily
solar calculation at the end of the day.  Each day's solar calculation takes about **25 minutes**. 

This is an example of how to calculate the solar radiation for a day's worth of data.
```
grass solar/cimis 
```
Always start in the cimis mapset to retain bash history.  In this example we are looking at the day of
August 1 2018.  It is assumed that the raw data has already been pushed to this processor and imported
into GRASS.
```
cd solar 
g.mapset 20180801
make --directory=~/spatial-cimis/g.cimis/etc/ -f solar.mk solar;
```
The make command will process the day's raw data and produce the necessary net radiation maps.  Once the calculation
has finished you can run the `g.list rast` command to verify you see the following rasters with the `-G` extension were
created.
```
g.list.rast type=rast pattern=ssetr*
```
```
ssetr
ssetr-G
ssetr-Gc
ssetr-Gi
ssetr-K
```

You can search multiple days to determine if any past days need the solar calculation.  For example if the month
of October raw data has been imported use this command to check each day has incomplete solar calculations.
```
for m in  201808??;do x=`g.list type=rast pattern=ssetr-G mapset=$m`;echo $m  $x;done 
```
```
20181001 ssetr-G
20181002
20181003
20181004 ssetr-G
20181005 ssetr-G
20181007
20181008
20181010 ssetr-G
20181011 ssetr-G
20181012 ssetr-G
20181013 ssetr-G
20181014 ssetr-G
20181015 ssetr-G
20181016 ssetr-G
20181017 ssetr-G
20181018 ssetr-G
20181019 ssetr-G
20181020 ssetr-G
20181021 ssetr-G
20181022 ssetr-G
20181023 ssetr-G
20181024 ssetr-G
20181025 ssetr-G
20181026 ssetr-G
20181027 ssetr-G
20181028 ssetr-G
20181029 ssetr-G
20181030 ssetr-G
20181031 ssetr-G
```

This list shows that days 10/2, 10/3, 10/7 and 10/8 did not have solar calculations.  In this case this is a known
GOES16 satellite outage due to solar activity so there is no data available for those days.

But if you check a month and see no solar calculations (no `ssetr-g` rasters exist) you can process an entire
months of raw data using the following loop.

```
for m in 201810??;do echo $m;  
  g.mapset $m; 
  make --directory=~/spatial-cimis/g.cimis/etc/ -f solar.mk solar;
done 
```

Note that using the `-n` switch will act as a dry run and show you what needs to be done without actually
executing the calculation for that day.
```
make –directory=~/spatial-cimis/g.cimis/etc/ -f solar.mk solar -n
```

### ETo Calculation
Once the solar calculation for the day is complete run the final ETo calculation.
```
sudo su - cimis
grass cimis/cimis 
cd cimis 
g.mapset 20180813 -c 
make --directory=~/spatial-cimis/g.cimis/etc --file=cimis.mk ETo 
```

### Automation

# GOESBOX 

## Software Configuration (Open Suse Leap 42.3 or newer)

### Incron

Incron setup for grb-box.cstars.ucdavis.edu or DWR receiver.  
[Download RPM package](https://software.opensuse.org/package/incron?search_term=incron) 
for OpenSuse Leap 42.3 and install.

`rpm -i /root/incron-0.5.10-2.1.x86_64.rpm`

Register startup script:  `insserv incron`.  
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
su - cimis ; git clone -b GOES-16-17 https://github.com/CSTARS/spatial-cimis
```

Pre-setup incron 
```
echo cimis >> /etc/incron.allow 
$grb-box=$(find /home/cimis/spatial-cimis/grb-box |grep –v README) 
sudo cp -v $grb-box /usr/local/grb-box 
sudo chmod 644 *.mk 
sudo chmod 754 goestcl 
chgrp cimis goesctl *.mk 

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

