The cg.cgi program is a grass command that is basically designed to
handle requests from the wms.cgi program.  This is an ancient methodology
that was designed in 2003, at the initial stages of the CIMIS program.

Despite strong objecctions from the Spatial CIMIS developers, the
wms.cgi interface has not been depreciated in the DWR framework

## Installation

Because the wms.cgi program is so very old, no strong attempt at a
simple installation has been made.  Instead users must follow the
steps below.

### cg.cgi installation

This is the grass command that reformats the WMS requests into grass
commands, and formats the data as XML.  This program calls a grass
command for EVERY date and EVERY mapset that is passed into the query.
Because of this, the program is quite suspetable to DOS attacks, even
simple queries from regular users can cause this DOS attacks.

``` bash
# Within this (cg.cgi) directory, run the following command
g.extension extension=cg.cgi url=. operation=add
```

This adds the `cg.cgi` command to the grass user.  In addition to
this, the user needs to set the `CG_ZIPCODE_DB` file for operation.
This is done with the `g.gisenv set=CG_ZIPCODE_DB=/app/cimis/cimis.db`
command for example.

### wms.cgi

In addition to the `cg.cgi` executable, the `wms.cgi` file connects
this to the internet.  This file needs to be moved to the executable
location of the new server, eg. /var/www/wms/wms.cgi.  In addition, an
`./htaccess` file like below, may need to be included as well.

```text
AddHandler cgi-script .cgi .pl
Options +ExecCGI
```

Once installed, the ~wms.cgi~ script needs to be modified to point to
the proper GISDBASE.  Look for this section in the script.

``` perl
# Need to set the proper GISDBASE for operation.
$CG_GISDBASE='/data/cimis/gdb';
```

And set the location appropriately.

## Tests

You can test the functions with the following commands.

``` bash
# Simple request for yesterday's ET data in EPSG_3310 format
cg.cgi x=100 y=100

#### Tests
You can test the functions with the following commands.

``` bash
# Simple request for yesterday's ET data in EPSG_3310 format
cg.cgi x=100 y=100
```

This responds with something like:

``` xml
<!-- Draft Spec for input -->
<!-- cg.cgi item='ETo,Rs,K,Rnl,Tx,Tn,U2,Rso' date='20190128' srid=3310 BBOX='-400000,-650000,600000,450000' WIDTH=500 HEIGHT=550 X='100' Y='100' -->
<data dates="20190128" first_date="20190128" last_date="20190128">
<DataPoint input_point="0" x="-200000" y="250000" lon="-122.3513" lat="40.2436" date="20190128" err="">
<ETo units="[mm]">1.45979632911733</ETo>
<Rs units="[W/m^2]">84.6775571826918</Rs>
<K>0.629347930007686</K>
<Rnl units="[W/m^2]">-38.5611876277877</Rnl>
<Tx units="[C]">19.23358</Tx>
<Tn units="[C]">9.552002</Tn>
<U2 units="[m/s]">1.374664</U2>
<Rso units="[W/m^2]">134.54808245998</Rso>
</DataPoint>
</data>
```

You can run the same example using a point

```bash
cg.cgi srid=4269 point=[-122.3512,40.2436]
```

Which is located at the same point as the previous

```xml
<!-- Draft Spec for input -->
<!-- cg.cgi item='ETo,Rs,K,Rnl,Tx,Tn,U2,Rso' date='20190128' srid=3310 BBOX='-400000,-650000,600000,450000' WIDTH=500 HEIGHT=550 X='100' Y='100' -->
<data dates="20190128" first_date="20190128" last_date="20190128">
<DataPoint input_point="0" x="-200000" y="250000" lon="-122.3513" lat="40.2436" date="20190128" err="">
<ETo units="[mm]">1.45979632911733</ETo>
<Rs units="[W/m^2]">84.6775571826918</Rs>
<K>0.629347930007686</K>
<Rnl units="[W/m^2]">-38.5611876277877</Rnl>
<Tx units="[C]">19.23358</Tx>
<Tn units="[C]">9.552002</Tn>
<U2 units="[m/s]">1.374664</U2>
<Rso units="[W/m^2]">134.54808245998</Rso>
</DataPoint>
</data>
```

In addition, you can ask for multiple points.  Additionally you can
request a set of dates, either separeted by commas, or a range with a
colon

```bash
cg.cgi srid=4269 point=[-122.3512,40.2436] point=[-123,40]
```

```bash
cg.cgi srid=4269 point=[-122.3512,40.2436] point=[-123,40] date=2019-01-10,2019-01-11
cg.cgi srid=4269 point=[-122.3512,40.2436]  date=2019-01-10:2019-01-15,2019-01-20
```

## WMS Script

The WMS script uses a basterized version of the OpenGIS WMS protocol.
You can test this from the command line, eg.

``` bash
perl wms.cgi "REQUEST=getfeatureinfo&SRID=4269&X=-123&Y=50&TIME=2019-01-10&BBOX=0,-90,180,90&HEIGHT=180&WIDTH=180" 2> /dev/null$
```
