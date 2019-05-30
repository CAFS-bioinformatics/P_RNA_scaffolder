#! /usr/bin/perl
#use strict;
if( @ARGV != 2 ) {
    print "Usage: $0 F.sam R.sam \n";
    exit 0;
}
my $fh1=shift @ARGV;
my $fh2=shift @ARGV;
my $INFILE;
open $INFILE, "< $fh1";
while(<$INFILE>)
{
   chomp($_);
    my @line = split(/\s/,$_);
    my $sum_soft=0;
    my @soft= ($line[5] =~ /(\d+)S/g);
    foreach my $soft (@soft)
    {
      $sum_soft+=$soft;
    }
    my $sum_match=0;
    my @match= ($line[5] =~ /(\d+)M/g);
    foreach my $match (@match)
    {
      $sum_match+=$match;
    } 
    if ($sum_soft/($sum_soft+$sum_match) > 0.2)
    {
      print $line[0]."\n";
    }
}

open $INFILE, "< $fh2";
while(<$INFILE>)
{
   chomp($_);
    my @line = split(/\s/,$_);
    my $sum_soft=0;
    my @soft= ($line[5] =~ /(\d+)S/g);
    foreach my $soft (@soft)
    {
      $sum_soft+=$soft;
    }
    my $sum_match=0;
    my @match= ($line[5] =~ /(\d+)M/g);
    foreach my $match (@match)
    {
      $sum_match+=$match;
    }
    if ($sum_soft/($sum_soft+$sum_match) > 0.2)
    {
      print $line[0]."\n";
    }
}
