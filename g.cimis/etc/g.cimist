#! /bin/bash

function fn2t() {
    local t;
    echo $(basename $1) | sed -e 's/PST-.*$//'
}

function cmp() {
    local t1=$(fn2t $1)
    local t2=$(fn2t $2)
    if [[ $t1 < $t2 ]]; then
	echo lt;
    elif [[ $t1 = $t2 ]]; then
	echo eq;
    else echo gt;
    fi;
}

function day_parms() {
    local m=$(g.gisenv MAPSET)
    local y=${m%????}
    local md=${m#????}
    local m=${md%??}
    local d=${md#??}
    echo "year=$y month=$m day=$d timezone=-8"
}

function solpos() {
    r.solpos -r $(day_parms)
}

function sretr() {
    solpos | grep sretr_hhmm | cut -d= -f 2 | sed -e 's/://'
}

function ssetr() {
    solpos | grep ssetr_hhmm | cut -d= -f 2 | sed -e 's/://'
}

function sretr_parms() {
    local sretr_hhmm
    eval $(solpos | grep sretr_hhmm)
    echo $(day_parms) hour=${sretr_hhmm%:??} minute=${sretr_hhmm#??:}
}


function ssetr_parms() {
    local ssetr_hhmm
    eval $(solpos | grep ssetr_hhmm)
    echo $(day_parms) hour=${ssetr_hhmm%:??} minute=${ssetr_hhmm#??:}
}

function daynight() {
    local sr
    local ss
    if [[ -n $2 ]]; then
	sr=$2;
    else
	sr=$(sretr)
    fi
    if [[ -n $3 ]]; then
	ss=$2;
    else
	ss=$(ssetr)
    fi
    local cmp=$(cmp $1 $sr)
    if [[ $cmp = "gt" ]]; then
	cmp=$(cmp $1 $ss)
	if [[ $cmp = "lt" ]]; then
	    echo day;
	else
	    echo night
	fi;
    else
	echo night
    fi
}

function prev() {
    local t1=$(fn2t $1)
    local ti
    local prev
    local pat
    if [[ -z $2 ]]; then
	pat='????PST-B2'
    else
	pat=$2
    fi
    for i in $(g.list type=rast pattern='????PST-B2' | sort); do
	ti=${i%PST-B2}
	if [[ $ti < $t1 ]]; then
	    prev=$i
	else
	    break
	fi
    done
    echo $prev
}

function risedayset() {
    local dn
    local pdn
    dn=$(daynight $1)
    local prev
    pdn="night"
    prev=$(prev $1)
    if [[ -n $prev ]]; then
	pdn=$(daynight $(prev $1))
    fi
    if [[ $dn = 'day' ]]; then
	if [[ $pdn = "night" ]]; then
	    echo sunrise $prev;
	else
	    echo day $prev;
	fi
    else
	if [[ $pdn = "day" ]]; then
	    echo sunset $prev;
	else
	    echo night $prev
	fi
    fi
}

# MAIN

OPTS=`getopt --long sretr:,ssetr: -- g.ct "$@"`
if [ $? != 0 ] ; then
    echo "Bad Command Options." >&2 ;
    exit 1 ;
fi

eval set -- "$OPTS"

while true; do
    case $1 in
#	--sretr) SRETR=$2; shift 2;;
#	--ssetr) SSTER=$2; shift 2 ;;
	-- ) shift; break;;
	*) shift; break;
    esac
done

CMD=$1
shift;

case $CMD in
     solpos | sretr | ssetr ) # Directory Commands
	$CMD $@;
	;;
     daynight | prev | risedayset ) # Identifiers
	$CMD $@;
	;;
     day_parms | sretr_parms | ssetr_parms ) # Grass helpers
	 $CMD $@;
	;;
    *)
	echo  "$CMD not found";
	;;
esac
