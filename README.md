# Spatial CIMIS

In November 2011, California Department of Water Resources have contracted for a revision to the current [Spatial CIMIS]([http://wwwcimis.water.ca.gov/cimis/cimiSatSpatialCimis.jsp) Evapotranspiration Model.   One requirement of this project is to make available the source code for the project.  This is available under the *cimis* code repository.  Most of the project is pretty specific to California, but  there are some parts that may be generally useful, mostly GRASS GIS functions.  

# Installation

Here are some short descriptions of the packages needed to run the CIMIS application.

## Production Machines

Some the packages that are required to run the Spatial CIMIS program are in the ELGIS package repository.  In addition, there are currently two different versions of the *geos* package.  Here are the packages used by the Spatial CIMIS application.  Note some of these packages are only required by the archiver or the processor, but are included in a single 
command for simplicity, and also to allow one machine to fulfill both roles. 

```
#!bash
EPEL=http://download.fedoraproject.org/pub/epel/6/x86_64
ELGIS=http://elgis.argeo.org/repos/6
sudo rpm -Uvh $EPEL/epel-release-6-8.noarch.rpm
sudo rpm -Uvh $ELGIS/elgis-release-6-6_0.noarch.rpm
sudo yum clean all
sudo yum install sqlite rsync wget curl perl cronie \
daemonize perl-Date-Manip perl-TimeDate \
perl-Test-Simple perl-Test-Pod perl-CPAN perl-Test-Fatal \
perl-Date-Calc perl-Crypt-SSLeay perl-XML-XPath perl-SOAP-Lite \
perl-XML-Simple perl-AppConfig
sudo yum --disablerepo=epel install geos
sudo yum install grass 
```

## Development Machines

The development machine needs to include packages that allow both the operation of the software, but also the compilation of the Spatial GOES code.  Therefore additional development packages need to be installed on these systems.  Use the following commands to install the required packages on the production machines.

```
#!bash
EPEL=http://download.fedoraproject.org/pub/epel/6/i386
ELGIS=http://elgis.argeo.org/repos/6
sudo rpm -Uvh $EPEL/epel-release-6-7.noarch.rpm
sudo rpm -Uvh $ELGIS/elgis-release-6-6_0.noarch.rpm
sudo yum clean all
sudo yum install sqlite rsync wget curl perl mercurial cronie \
daemonize perl-Date-Manip perl-TimeDate perl-SOAP-Lite perl-XML-Simple
sudu yum --disablerepo=epel install geos geos-devel
sudo yum install grass grass-devel
```

Steps to install repositories, and required software, for Spatial CIMIS.  The additional special installation of the geos packages is because the current epel version of geos is ahead of the version used in the the grass software.  This may change over time.

### Compiling PERL Modules

Not all PERL Modules are available via redhat.  These can be compiled on the development machine, and copied unto the test and production machines.  Missing PERL modules include:
```
#!bash
mods="SOAP::Lite XML::Simple AppConfig YAML Test::POD"
cpan $mods
```

### Compiling Proj.4

RedHat comes with a standard proj.4 package.  This is the package that is used for projecting between coordinate systems in grass, among other software packages.  Unfortunately, the standard proj.4 package does not include a projection of the GOES satellite.  Therefore, a patched version of the software needs to applied to the systems.  This can be built on the development machine, and then deployed on the test and production machines. 

```
#!bash
# First get the proj source
sudo yumdownloader --source proj
#Setup your build environment ( this uses home directory)
sudo yum install rpm-build redhat-rpm-config
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros
# Build the package (if this fails you made need to install more dependencies)
rpmbuild --recompile grass-6.4.1-3.el6.src.rpm
Compilation steps for grass.
```
