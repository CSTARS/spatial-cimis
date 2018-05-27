# GRB-BOX

On the grb-box, we have two icrontab defined processes and and one cron clean
up process.

The incron commands are processed by the goesctl command.  This is a small
wrapper around some makefiles.  

## incrontab

The incrontab file looks something like this:

``` text
/grb/raw/fulldisk/ IN_CREATE /home/quinn/spatial-cimis/goesctl raw="$@/$#" CA
/home/quinn/CA IN_CREATE /home/quinn/spatial-cimis/goesctl CA="$@/$#" push
```
The first line monitors the incoming full-disk images, and runs the
crop/conversion to the California domain.  The second line monitors newly
created California files, and pushes them along to the cimis-goes-r server.


## convert.mk

The convert.mk Makefile takes in raw images, and cuts out California.  In
addition, the converison renames the images into a time-stamped based (PST)
format.

In the incrontab, this is run with a single image, however, multiple images
can be run. In fact, by default the command checks every image in
/grb/raw/fulldisk

``` bash
spatial-cimis/grb-box/goesctl CA 
```

Here's an example that converts the last hour of images.

```bash
spatial-cimis/grb-box/goesctl raw="$(find /grb/raw/fulldisk -name
satimage-\*-B2.pgm -newermt $(date --date='now -12 hours' --iso=seconds) | tr
'\n' ' ')" CA 
```

## push.mk

The push.mk component is just an rsync process that pushes new CA files to the
next server.  Again, in the incrontab file, this is run on a newly created
file, but by default, the command runs on all files in the CA directory

``` bash
spatial-cimis/grb-box/goesctl push
```
