#! /usr/bin/perl -w
use CGI  qw/:standard -oldstyle_urls/;
use CGI::Carp qw(fatalsToBrowser);
use File::Temp qw(tempdir);

# Setup up GRASS
my $dir=tempdir('/tmp/grass6-wms-XXXX',CLEANUP=>1);
open(GISRC,">$dir/gisrc") || die "Can't open GISRC file $dir/gisrc";
printf GISRC "LOCATION_NAME: CA\nMAPSET: www-data\nGISDBASE: /var/lib/gdb\nGRASS_GUI: text\n";
close GISRC;

$ENV{GISBASE}=`pkg-config --variable=prefix grass`;
chomp $ENV{GISBASE};
my $addon=`. /etc/default/cg; echo CG_GRASS_ADDON_PATH`;
chomp $ENV{PATH};
$ENV{PATH}=sprintf "%s:%s",$addon,$ENV{PATH};
$ENV{LD_LIBRARY_PATH}=`pkg-config --variable=libdir grass`;
chomp $ENV{LD_LIBRARY_PATH};
$ENV{GISRC}="$dir/gisrc";

my $q=new CGI;

my $date=$q->param('TIME');
my $zipcode=$q->param('ZIPCODE');
my $item=$q->param('QUERY_LAYERS');
my $BBOX=$q->param('BBOX');
my $HEIGHT=$q->param('HEIGHT');
my $WIDTH=$q->param('WIDTH');
my $X=$q->param('X');
my $Y=$q->param('Y');
my $srid=$q->param('SRID');

my $cmd;
if (defined(param('REQUEST')) and (lc(param('REQUEST')) eq 'getfeatureinfo')) {
    $cmd=join(' ',
	      ("cg.cgi",
	       ($item)?"item=$item":'',
	       ($zipcode)?"zipcode=$zipcode":'',
	       ($date)?"date=$date":'',
	       ($srid)?"srid=$srid":'',
	       ($BBOX)?"BBOX=$BBOX":'',
	       ($HEIGHT)?"HEIGHT=$HEIGHT":'',
	       ($WIDTH)?"WIDTH=$WIDTH":'',
	       ($X)?"X=$X":'',
	       ($Y)?"Y=$Y":'',
	      )
	);
    
    my $xml=`$cmd`;

    print STDERR "$cmd","\n";
    # Send XML document;
    print $q->header(-type=>'text/xml');
    print $xml;

} else {
    die "No Options Specified";
}
