#!/bin/bash
#
# Pulls daily UCD solar and ETo grass mapsets to the DWR processor
# uses the existing GOES15 receiver as an ssh proxy to UCD
# should be run as the cimis user on the DWR processor(s)

TUNNELHOST=10.28.200.5				# tunneling host at DWR
UCDHOST=cimis-goes-r.cstars.ucdavis.edu		# current UCD CIMIS processor
SDIR=/home/cimis/gdb/solar
CDIR=/home/cimis/gdb/cimis

function check-solar ()
{
if [[ -d $SDIR/$day ]];then
	if [[ $opt = "" ]];then
       		# the GOES17 mapset already exists, don't pull UCD
		echo
	       	echo "$SDIR/$day already exists, not pulling"
		echo
	elif [[ $opt = "-f" ]];then
		echo
		echo "Pulling $day solar data"
		echo
		sleep 2
		get-solar
		echo
		echo ======================================================================
		echo "Finished pulling solar.  You may want to run:  g.cimis-eto.sh $day"
		echo ======================================================================
		echo
	fi
else
	echo
	echo "Pulling $day solar data"
	echo
	sleep 2
	get-solar
	echo
	echo ======================================================================
	echo "Finished pulling solar.  You may want to run:  g.cimis-eto.sh $day"
	echo ======================================================================
	echo
fi
}
function check-eto ()
{
if [[ -d $CDIR/$day ]];then
        if [[ $opt = "" ]];then
                # the GOES17 mapset already exists, don't pull UCD
                echo
       		echo "$CDIR/$day already exists, not pulling"
                echo
        elif [[ $opt = "-f" ]];then
		echo "Pulling $day ETo data"
                echo
                sleep 2
                get-eto
                echo
		echo ====================================================================
                echo "Finished pulling ETo.  You may want to run:  g.cimis-eto.sh $day"
		echo ====================================================================
                echo
        fi
else
	echo
	echo "Pulling $day ETo data"
	echo
	sleep 2
	get-eto
	echo
	echo ====================================================================
	echo "Finished pulling ETo.  You may want to run:  g.cimis-eto.sh $day"
	echo ====================================================================
	echo
fi
}
function get-solar ()
{
rsync -avz -e "ssh -i /home/cimis/.ssh/ucdgoes -A cimis@$TUNNELHOST ssh -i /home/cimis/.ssh/dwr-receiver" cimis@$UCDHOST:$SDIR/$day $SDIR
}
function get-eto ()
{
rsync -avz -e "ssh -i /home/cimis/.ssh/ucdgoes -A cimis@$TUNNELHOST ssh -i /home/cimis/.ssh/dwr-receiver" cimis@$UCDHOST:$CDIR/$day $CDIR
}

if [[ $1 = [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]];then
        day=$1
	opt=$2
	check-solar
	check-eto
elif [[ $1 = "" ]];then
        day=$(date --date=yesterday +%Y%m%d)
	opt=""
	check-solar
	check-eto
elif [[ $1 = "-f" && $2 = "" ]];then
        day=$(date --date=yesterday +%Y%m%d)
	opt="-f"
	check-solar
	check-eto
else
        echo
        echo "Usage:  g.cimis-pull-solar-ucd.sh [YYYYMMDD] [OPTION]"
        echo
        echo "          -f (force download)"
        echo
        echo "        Default date is yesterday"
        echo
        echo "Examples:"
        echo "  g.cimis                 pull yesterday's solar and eto data from UCD."
        echo "  g.cimis -f              force pull even with existing data present. "
        echo "  g.cimis 20191112        pull that day's data."
        echo "  g.cimis 20191112 -f     force pull that day's data."
fi
