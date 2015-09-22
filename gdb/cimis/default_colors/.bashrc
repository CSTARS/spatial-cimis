test -z  && . /etc/profile
test -e ~/.alias && . ~/.alias
umask 022
PS1='GRASS:\w > '
export GRASS_WIDTH=500
export GRASS_HEIGHT=550

PATH=/home/goes/bin:$PATH

#
# new_mapset - Adds a new mapset to the current location, and moves there
#
function new_mapset {
	local mapset=$1;
	local gisdbase=`g.gisenv GISDBASE`;
	local location=`g.gisenv LOCATION_NAME`;
	if [ -e $gisdbase/$location/$mapset ]; then
	    echo "mapset $mapset or something like it exists";
	else 
	    mkdir  $gisdbase/$location/$mapset;
	    cp $gisdbase/$location/PERMANENT/DEFAULT_WIND \
		$gisdbase/$location/$mapset/WIND;
	fi
	mapset $mapset;
}

function mapset { perl -i -p -e "s/^MAPSET:.*/MAPSET: $1/" $GISRC; }
function cdm { 
	eval `g.gisenv | sed -e 's/^/local /'`
    	cd $GISDBASE/$LOCATION_NAME/$MAPSET
}


#
# These are CIMIS specific site files.
#
function cimis.sites.pg { 
    eval `g.gisenv | sed -e 's/^/local /'`
    local sdir=$GISDBASE/$LOCATION_NAME/$MAPSET/site_lists
    [ -d $sdir ] || mkdir $sdir;
    local parm=$1;
    if [ -z $2 ]; then
        local date=`g.gisenv MAPSET`;
    else
        local date=$2;
    fi;
    psql -A -F'|' -t -c "select x(st_casil83),y(st_casil83),st_elevation*12*2.54/100,\
 '#'||st_number||' %'||${parm}||' @'||CASE WHEN ${parm}_qc is null THEN 'OK' ELSE ${parm}_qc END  \
from station join daily using (st_number) \
where d_date='$date' and $parm is not null and (${parm}_qc is null or ${parm}_qc = 'Y') \
order by st_number;" -h $PG_HOST -d $PG_DBASE > $sdir/$parm;
}

export PATH="/usr/local/grass5/bin:/usr/local/grass5/scripts:/var/lib/gforge/chroot/home/users/goes/bin:/usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/usr/games:/usr/local/pkg/pgi/linux86/bin:/home/goes/bin"
export HOME="/var/lib/gforge/chroot/home/users/goes"
