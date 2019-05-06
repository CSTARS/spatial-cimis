#! /usr/bin/perl -w
use strict qw (vars refs);
#use Getopt::Long qw[:config prefix_pattern=(--|-|) ];
#use Pod::Usage;

my $header=1;
my $delim=',';
my $nodata='*';
my $mapset=1;    # Always true
my @rast;


#%Module
#%  description: CIMIS specific command to create zipcode_summaries
#%  keywords: CIMIS,evapotranspiration
#%End
#%flag
#% key: h
#% label: noheader
#% description: Do not print header information
#%end

#%flag
#% key: m
#% label: nomapset
#% description: Do not mapset name to output
#%end

#%option
#% key: delimiter
#% type: string
#% description: delimiter for table
#% multiple: no
#% answer: ,
#% required : no
#%end

#%option G_OPT_R_MAP
#% key: rast
#% type: string
#% description: Default Rasters to include
#% multiple: yes
#% answer: Tn,Tx,U2,ea,Gc,G,K,Rnl,ETo
#% required : yes
#%end

#%option
#% key: nodata
#% type: string
#% description: What to replace your no-data values with 
#% multiple: no
#% required : no
#% answer : *
#%end

if ( !$ENV{'GISBASE'} ) {
    die "You must be in GRASS GIS to run this program.\n";
}

if (!defined($ARGV[0]) or ($ARGV[0] ne '@ARGS_PARSED@')) {
    my $arg = "";
    for (my $i=0; $i < @ARGV;$i++) {
        $arg .= " $ARGV[$i] ";
    }
    system("$ENV{GISBASE}/bin/g.parser $0 $arg");
    exit;
}

#GetOptions(
#	   "delimiter=s"=>\$delim,
#	   "header!"=>\$header,
#	   "nodata=s"=>\$nodata,
#	   "mapset!"=>\$mapset,
#	   "rast=s"=>\@rast,	
#	  );

$delim=$ENV{GIS_OPT_DELIMITER};

if ( $ENV{GIS_FLAG_NOHEADER} ) {
    $header=0;
}

$nodata=$ENV{GIS_OPT_NODATA};

if ( $ENV{GIS_FLAG_NOMAPSET} ) {
    $mapset=0;
}

# Get rasters of interest
#@rast=(qw(Tn Tx U2 ea Gc G K Rnl ETo FAO_Rso)) unless @rast;

@rast = split(/,/,$ENV{GIS_OPT_RAST});

if ($mapset) {
    $mapset=`g.gisenv MAPSET`;
    chomp $mapset;
}

my @g_rast=('zipcode_2012@PERMANENT');
my @g_rast_col;
for (my $i=0;$i<=$#rast;$i++) {
  if (system("g.findfile element=cellhd file=$rast[$i] >/dev/null") == 0) {
    push @g_rast,$rast[$i];
    $g_rast_col[$i]=$#g_rast;
 }
}

system('g.region rast=zipcode_2012@PERMANENT');
my %zip;
my $g_rast=join(',',@g_rast);
#print STDERR "r.stats -1 $g_rast\n";
open(STATS, "r.stats --quiet -1 $g_rast |") || die "Can't do r.stats -1 $g_rast";
while(<STATS>) {
  my @row=split;
  unless ($row[0] eq '*' or $row[1] eq '*') {
    #count for that row
    $zip{$row[0]}->[0]++;
    for (my $i=1;$i<=$#row;$i++) {
      $zip{$row[0]}->[$i]+=$row[$i];
    }
  }
}
close(STATS);
# Reset region
system('g.region -d');

# Now print them in ZIPCODE order
if ( $header ) {
  my @head = ('zipcode');
  unshift  @head,'mapset'  if ($mapset) ;
  print ( join($delim,@head,@rast),"\n" );
}
foreach my $z (sort keys %zip) {
  my @out=($z);
  my $in=$zip{$z};
  for(my $i=0;$i<=$#rast;$i++) {
    push @out,sprintf "%.2f",$g_rast_col[$i]?$in->[$g_rast_col[$i]]/$in->[0]:$nodata;
  }
  unshift @out,$mapset if ($mapset) ;
  print join($delim,@out),"\n";
}

