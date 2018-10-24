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

# Feed Production Processors
