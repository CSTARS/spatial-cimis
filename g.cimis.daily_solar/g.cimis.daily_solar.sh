#!/usr/bin/env bash

############################################################################
#
# MODULE:       g.cimis.daily_solar
# AUTHOR(S):    Quinn Hart 
# PURPOSE:      Use GOES visible satelitte data to calculate a daily solar insolation
# COPYRIGHT:    (C) 2024 by Quinn Hart
#
#               This program is free software under the GNU General Public
#               License (>=v2). Read the file COPYING that comes with GRASS
#               for details.
#
#############################################################################
# Change to 3 for working
DEBUG=0

#%Module
#%  description: Runs standard Spatial CIMIS Daily Insolation Calculations
#%  keywords: CIMIS evapotranspiration
#%End
#%flag
#% key: f
#% description: force commands to be run regardless if files exist
#% guisection: Main
#%end
#%flag
#% key: s
#% description: save ALL intermediate files
#% guisection: Main
#%end
#%option
#% key: pattern
#% type: string
#% description: Replace pattern '[01][0-9][0-2][0-9]PST-B2' for testing only 
#% required: no
#% guisection: Main
#%end
#%option
#% key: pst
#% type: string
#% description: Replace PST in filename w/ this.  Used for testing only
#% required: no
#% guisection: Main
#%end


function G_verify_mapset() {
  if [[ ! ${GBL[YYYYMMDD]} =~ ^20[012][0-9][01][0-9][0-3][0-9]$ ]]; then
    g.message -e "Mapset ${GBL[YYYYMMDD]} not valid date format"
    exit 1
  fi
}

function G_linke() {
  local closest=(XX 01 01 01 01 07 07 \
                    07 07 07 07 15 15 15 15 \
                    15 15 15 21 21 21 \
                    21 21 21 21 28 28 28 \
                    28 28 28 28 )
  GBL[linke]="linkeT_${GBL[MM]}${closest[${GBL[DD]}]}@500m"
}

# Get the earliest sunrise and latest sunset
function G_sunrise_sunset() {
  if ! (r.info -r sretr > /dev/null 2>&1 && r.info -r ssetr  > /dev/null 2>&1) || ${GBL[force]}; then 
    g.message -d debug=$DEBUG  message="r.iheliosat --overwrite elevation=${GBL[elevation]} linke=${GBL[linke]} sretr=sretr ssetr=ssetr year=${GBL[YYYY]} month=${GBL[MM]} day=${GBL[DD]}"
    r.iheliosat --quiet --overwrite elevation=${GBL[elevation]} linke=${GBL[linke]} sretr=sretr ssetr=ssetr year=${GBL[YYYY]} month=${GBL[MM]} day=${GBL[DD]} timezone=${GBL[tz]}
  fi
  eval $(r.info -r sretr) && GBL[sunrise]=${min%.*}
  eval $(r.info -r ssetr) && GBL[sunset]=${max%.*}
}

### These functions are called at each timestep
# Calculate the integrated Clear sky radiance 
function rast_Gi() {
  local h=${1:0:2}
  local m=${1:2:2}
  local Gi=${h}${m}${GBL[PST]}-Gi
  if (! r.info -h map=$Gi >/dev/null 2>&1 ) || ${GBL[force]}; then
    local cmd="r.iheliosat  --quiet --overwrite elevation=${GBL[elevation]} linke=${GBL[linke]} total=$Gi year=${GBL[YYYY]} month=${GBL[MM]} day=${GBL[DD]} hour=${h} minute=${m} timezone=${GBL[tz]}"
    g.message -d debug=$DEBUG  message="$cmd"
    $cmd
  fi
  echo "'$Gi@${GBL[YYYYMMDD]}'"
}

# Calculate the maximum raster value.  We can not just use the max of the raster
# since we get things like sunglints that give bad data, so we take the max of a
# 5x5 region, which is meant to get the brightest possible cloud top.  Save
# this, since it is very expensive to calculate
function max5x5() {
  local B=$1
  local t=${B}_5x5
  if ! (g.gisenv get="$t" store=mapset 2>/dev/null) || ${GBL[force]}; then
    local cmd="r.neighbors --quiet --overwrite input=$B output=$t size=5 method=average"
    g.message -d debug=$DEBUG message="$cmd"
    $cmd
	  eval $(r.info -r $t)
    g.gisenv set="$t=${max%.*}" store=mapset
    ${GBL[save]} || g.remove --quiet -f type=rast name=$t
  fi
  local max=$(g.gisenv get="$t" store=mapset)
  g.message -d debug=$DEBUG message="max($t)=$max"
  echo $max
}

# Get the last 14 days for the matching filename.  We use this to get the
# minimum value from the last 14 days, including the current day.
function rast_P() {
  local B=$1
  local hm=${1:0:4}
  local P=${hm}${GBL[PST]}-P
  local prev=
  if (! r.info -r map=$P > /dev/null 2>&1) || ${GBL[force]}; then
	  for i in $(seq -14 0); do 
	    m=$(date --date="${GBL[YYYYMMDD]} + $i days" +%Y%m%d);
      #g.message -d debug=$DEBUG message="r.info $B@$m"
      if (r.info -r map="$B@$m" > /dev/null 2>&1); then
        prev+="'$B@$m',"
        #g.message -d debug=$DEBUG message="found $B@$m, prev=$prev"
      fi
    done
    prev=${prev:0:-1}
    local cmd="r.mapcalc  --quiet --overwrite expression=\"$P\"=min($prev)"
    g.message -d debug=$DEBUG message="$cmd"
    $cmd
  fi
  echo "'${P}@${GBL[YYYYMMDD]}'"
}

function rast_K() {
  local B=$1
  local hm=${B:0:4}
  local K=${hm}${GBL[PST]}-K

  if (! r.info -r map=$K > /dev/null 2>&1 ) || ${GBL[force]}; then
    local X=$(max5x5 $B)
    local P=$(rast_P $B)
    local exp="\"$K\"=if(($X-'$B')/($X-$P)>0.2,\
	  min(($X-'$B')/($X-$P),1.09),\
	  min(0.2,(1.667)*(($X-'$B')/($X-$P))^2+(0.333)*(($X-'$B')/($X-'$B'))+0.0667))"

    g.message -d debug=$DEBUG message="r.mapcalc expression=\"$exp\""
    r.mapcalc --overwrite  --quiet expression="$exp"
  fi
  echo "'$K@${GBL[YYYYMMDD]}'"
}

function rast_G() {
  local B=$1
  local hm=${B:0:4}
  local G=${hm}${GBL[PST]}-G
  local Gi=$(rast_Gi $B)
  local K=$(rast_K $B)

  local pB=$2
  local exp

  if (! r.info -r $G >/dev/null 2>&1 ) || ${GBL[force]}; then
    if [[ -z $pB  ]]; then
      exp="\"$G\"=$Gi*$K"
    else
      local pGi=$(rast_Gi $pB)
      local pG=$(rast_G $pB)
      local pK=$(rast_K $pB)
      exp="\"$G\"=$pG+(($pK+$K)/2*($Gi-$pGi))"
    fi
    g.message -d debug=$DEBUG message="r.mapcalc expression=\"$exp\""
    r.mapcalc  --quiet --overwrite expression="$exp"
  fi
  echo "'$G@${GBL[YYYYMMDD]}'"
}


function integrated_G() {
  local pB=
  for B in $(g.list type=rast pattern="${GBL[pattern]}" | sort); do
    g.message -d debug=$DEBUG message="$B"
    local h=${B:0:2}
    local m=${B:2:2}
    local min=$((10#$h*60+10#$m))
    local G
    g.message -d debug=$DEBUG message="[[ $min -gt ${GBL[sunrise]} ]]"
    if [[ $min -gt ${GBL[sunrise]} ]]; then
      if [[ $min -lt ${GBL[sunset]} ]]; then
        if [[ -z $pB ]]; then
          G=$(rast_G $B)
          g.message -d debug=$DEBUG message="sunrise $G"
        else
          G=$(rast_G $B $pB)
          g.message -d debug=$DEBUG message="add $G"
        fi
        pB=${B}
      else
        if (! r.info -r G >/dev/null 2>&1 ) || ${GBL[force]}; then
          pGi=$(rast_Gi $pB)
          pK=$(rast_K $pB)
          pG=$(rast_G $pB)
          local exp="G=$pG+($pK*($Gi-$pGi))"
          g.message -d debug=$DEBUG message="$exp"
          r.mapcalc  --quiet --overwrite expression="$exp"
          break
        fi
      fi
    fi
  done
}


## MAIN Program
if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

# save command line
if [ "$1" != "@ARGS_PARSED@" ] ; then
    exec g.parser "$0" "$@"
fi

# CIMIS uses YYYYMMDD for all standard mapsets
# Global variables
eval $(g.gisenv)
declare -g -A GBL
GBL[GISDBASE]=$GISDBASE
GBL[MAPSET]=$MAPSET
GBL[LOCATION_NAME]=$LOCATION_NAME
GBL[YYYYMMDD]=${GBL[MAPSET]}
GBL[YYYY]=${MAPSET:0:4}
GBL[MM]=${MAPSET:4:2}
GBL[DD]=${GBL[YYYYMMDD]:6:2}

GBL[tz]=-8
GBL[elevation]=Z@500m

# Get Options
if [ $GIS_FLAG_F -eq 1 ] ; then
  GBL[force]=true
else
  GBL[force]=false
fi

if [ $GIS_FLAG_S -eq 1 ] ; then
  GBL[save]=true
else
  GBL[save]=false
fi

# test if parameter present:
if [ -n "$GIS_OPT_PST" ] ; then
  GBL[PST]="$GIS_OPT_PST"
else
  GBL[PST]='PST'
fi

# test if parameter present:
if [ -n "$GIS_OPT_PATTERN" ] ; then
  GBL[pattern]="$GIS_OPT_PATTERN"
else
  GBL[pattern]='[01][0-9][0-2][0-9]PST-B2'
fi

# Set Globals
G_verify_mapset
G_linke
G_sunrise_sunset
g.message -d debug=$DEBUG message="$(declare -p GBL)"
integrated_G
