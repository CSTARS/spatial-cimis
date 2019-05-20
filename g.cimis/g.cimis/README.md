# Spatial CIMIS Grass

This includes a number of scripts that are used to run the grass
program.  The main script is `cg`, but there are a number of others
included.

You can install these with the command below.  

## DEBIAN

``` bash
GH=$(pkg-config --variable=prefix grass) # /usr/lib/grass64
GRASS_ADDON=~/grass
mkdir -p ${GRASS_ADDON}/scripts 
make GRASS_HOME=. MODULE_TOPDIR=${GH} INST_DIR=${GRASS_ADDON} install
```

## REDHAT

Note for REDHAT, you need to compile your own version of grass (see
github qjhart.grass-addons).

``` bash
version=6.4.4
GH=~/rpmbuild/BUILD/grass-${version}
GHLIB=/usr/lib64
GRASS_ADDON=~/grass
make GRASS_HOME=. MODULE_TOPDIR=${GH} INST_DIR=${GRASS_ADDON} install
```
