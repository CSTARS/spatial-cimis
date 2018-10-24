# Spatial CIMIS

For 2018 spatial CIMIS will begin processing the next generation GOES-16/17
data.  This will require new infrastructure (new dish and servers) and a slightly
modified spatial CIMIS toolset to process the new spatial data.

In November 2011, California Department of Water Resources have
contracted for a revision to the current [Spatial
CIMIS]([http://wwwcimis.water.ca.gov/cimis/cimiSatSpatialCimis.jsp)
Evapotranspiration Model.  One requirement of this project is to make
available the source code for the project.  This is available under
the *cimis* code repository.  Most of the project is pretty specific
to California, but there are some parts that may be generally useful,
mostly GRASS GIS functions.

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

## Package Geo::Proj4 and patching proj.4
This module is not required for GOES-16/17 processing.

## Install the grass add-ons

Follow the instructions for installing a patched version of proj at
https://github.com/qjhart/qjhart.grass-addons.  After these are
compiled you will have two binaries, `r.solpos` and `r.in.gvar` in
``~/grass/bin`.

## Install Spatial CIMIS

Finally, we can install the spatial CIMIS program.  The files in this
repository are designed to be installed into the base directory.  The
following items need to be installed.

### RPM Package

VERSION=1.0.2
``` bash
VERSION=1.0.2
cd ~/spatial-cimis/rpmbuild/SOURCES/cimis-${VERSION}
# There are others....
sudo rsync ~cimis/grass . -a -v --exclude=*~
```

``` bash
tar -czf ~/spatial-cimis/rpmbuild/SOURCES/cimis-${VERSION}.tar.gz 

sudo yum install cpanspec rpm-build;
rpmbuild -ba ~/spatial-cimis/rpmbuild/SPECS/cimis.spec 
```


### GrassModules

The grass scripts to run the program are installed into ~/grass.  This
includes the script and etc files.  Follow the instructions in the
[grassmodules/README.md](grassmodules/README.md) files.

### Grass database, ~/gdb

A working copy of the a grass database needs to be included.  A
skeleton version is available in the `spatial-cimis/gdb` directory.  You can
install that with: 

``` bash 
cd ; rsync -a -v spatial-cimis/gdb .  
```

Alternatively, you may simply start with an existing working grass
database, the most important components are five LOCATIONS 

  * `GOES15-SEP23-MAR20` RAW GOES Imagefiles for fall-winter
  * `GOES15-MAR20-SEP` Raw GOES Images for spring-summer
  * `GOES15` Symbolic link to current GOES data
  * `ca_daily_vis` CA projection of 
  * `cimis` Final Spatial CIMIS output



## Production Machines

Some the packages that are required to run the Spatial CIMIS program
are in the ELGIS package repository.  In addition, there are currently
two different versions of the *geos* package.  Here are the packages
used by the Spatial CIMIS application.  Note some of these packages
are only required by the archiver or the processor, but are included
in a single command for simplicity, and also to allow one machine to
fulfill both roles.

```
#!bash
sudo yum install sqlite rsync wget curl perl cronie boost \
perl-JSON perl-Date-Manip perl-TimeDate perl-Test-Pod \
perl-SOAP-Lite perl-XML-Simple perl-Date-Calc \
perl-CGI perl-XML-Writer perl-DBI perl-DBDSQLite
sudu yum install geos grass
```
