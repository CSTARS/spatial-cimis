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

### GrassModules

### Grass database, ~/gdb

# GOESBOX Configuration

## Incron Setup

# Final Configuration

## PushingGOES16 ETo Rasters and webAPI

### UCD GOES16 replaced GOES15 Data
As of October 23rd 2018 the production DWR and UCD Spatial CIMIS processors no longer processes GOES15 data from their respective on site dishes and receivers.  Instead they pull daily GOES16 CIMIS data products from the UCD GOES16 processor and use existing processes to continue to provide raster outputs, Arc/Info ASCII Grid output as well as ETo data for the webAPI.

Each GOES15 processor run scripts as the `cimis` user to accomplish this.

3:15am `/home/cimis/bin/cg.tunnel` 

Pulls daily GOES16 grass maps to `/home/cimis/gdb/cimis`

3:30am `/home/cimis/bin/cg.grass.script /home/cimis/bin/cg.daily.output`

The `cg.daily.output` grass script runs a modified version of the raster output grass makefile `png-special` which creates the daily raster images and zipcodes.
