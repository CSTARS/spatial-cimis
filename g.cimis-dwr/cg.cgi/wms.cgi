#! /usr/bin/perl -w
use CGI  qw/:standard -oldstyle_urls/;
use CGI::Carp;
use File::Temp qw(tempdir);
use XML::XPath;
use XML::XPath::Parser;

my $xml;
my $q=new CGI();

# Read configuration
$CG_GISDBASE=`. /data/quinn/spatial-cimis/config.sh echo \$CG_GISDBASE`;
chomp $CG_GISDBASE;
$CG_GISDBASE='/data/cimis/gdb';

my $date=$q->param('TIME');
my $zipcode=$q->param('ZIPCODE');
my $item=$q->param('QUERY_LAYERS');
my $BBOX=$q->param('BBOX');
my $HEIGHT=$q->param('HEIGHT');
my $WIDTH=$q->param('WIDTH');
my $X=$q->param('X');
my $Y=$q->param('Y');
my $srid=$q->param('SRID');
my $fail_on_err=$q->param('FAIL_ON_ERR') || 'on_last';

my $cmd;
if (defined(param('REQUEST')) and (lc(param('REQUEST')) eq 'getfeatureinfo')) {
    $cmd=join(' ',
	      ("grass --text $CG_GISDBASE/cimis/quinn --exec cg.cgi",
	       ($item)?"item=$item":'',
	       ($zipcode)?"zipcode=$zipcode":'',
	       ($date)?"date=$date":'',
	       ($srid)?"srid=$srid":'',
	       ($BBOX)?"bbox=$BBOX":'',
	       ($HEIGHT)?"height=$HEIGHT":'',
	       ($WIDTH)?"width=$WIDTH":'',
	       ($X)?"x=$X":'',
	       ($Y)?"y=$Y":'',
	      )
	);

    print $cmd;

    $xml=`$cmd`;
    my $status=200;
    if ($fail_on_err eq 'never') {
	$status=200;
    } elsif ($fail_on_err eq 'on_missing') {
	my $xp = XML::XPath->new(xml=>$xml);
	my $size = $xp->find("/data/DataPoint[attribute::err='date_not_found']")->size;
	if ($size > 0) {
	    $status=503;
	}
    } else {
	my $yesterday=`date --date=yesterday --iso`;
	chomp $yesterday;
	my $xp = XML::XPath->new(xml=>$xml);
	my $size = $xp->find("/data/DataPoint[attribute::err='date_not_found'][attribute::date='$yesterday']")->size;
	if ($size > 0) {
	    $status=503;
	}
    }
    print $q->header(-status=>$status,
		     -type=>'text/xml');
    print $xml;

} else {
    die "No Options Specified";
}
