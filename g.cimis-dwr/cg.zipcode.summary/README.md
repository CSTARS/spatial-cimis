# cg.zipcode.summary

cg.zipcode.summary is a grass program that summerizes the GOES-15
raster data over the 2012 zipcode data.  Data is written to stdout,
and this is used by the make files in g.cimis-dwr to fill the sqlliate
database with zipcode data.

In order for this application to work, it requires the zipcode data in
the zipcode mapset in the goes-15/cimis GIS_DBASE/LOCATION.

