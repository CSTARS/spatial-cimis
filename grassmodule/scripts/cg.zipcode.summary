#! /usr/bin/perl -w
use strict qw (vars refs);
use Getopt::Long qw[:config prefix_pattern=(--|-|) ];
use Pod::Usage;

my $header=1;
my $delim=',';
my $nodata='*';
my $mapset=1;
my $count=0;
my @rast;

GetOptions(
	   "delimiter=s"=>\$delim,
	   "header!"=>\$header,
	   "nodata=s"=>\$nodata,
	   "mapset!"=>\$mapset,
	   "count!"=>\$count,
	   "rast=s"=>\@rast,	
	  );

# Get rasters of interest
@rast=(qw(Tn Tx U2 ea Gc G K Rnl ETo FAO_Rso)) unless @rast;
@rast = split(/,/,join(',',@rast));

if ($mapset) {
    $mapset=`g.gisenv MAPSET`;
    chomp $mapset;
}

my @g_rast=('zipcode_2012@zipcode');
my @g_rast_col;
for (my $i=0;$i<=$#rast;$i++) {
  if (system("g.findfile element=cellhd file=$rast[$i] >/dev/null") == 0) {
    push @g_rast,$rast[$i];
    $g_rast_col[$i]=$#g_rast;
 }
}

system('g.region rast=zipcode_2012@zipcode');
my %zip;
my $g_rast=join(',',@g_rast);
print STDERR "r.stats -1 $g_rast\n";
open(STATS, "r.stats -1 $g_rast |") || die "Can't do r.stats -1 $g_rast";
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
  unshift @head,'count' if ($count) ;
  print ( join($delim,@head,@rast),"\n" );
}
foreach my $z (sort keys %zip) {
  my @out=($z);
  my $in=$zip{$z};
  for(my $i=0;$i<=$#rast;$i++) {
    push @out,sprintf "%.2f",$g_rast_col[$i]?$in->[$g_rast_col[$i]]/$in->[0]:$nodata;
  }
  unshift @out,$mapset if ($mapset) ;
  unshift @out,$in->[0] if ($count) ;
  print join($delim,@out),"\n";
}

