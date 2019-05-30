#!/usr/bin/perl -w 
use strict;
if( @ARGV != 3 ) {
    print "Usage: $0  SAM-file filter-ID-file ID-in-SAM-file \n";
    exit 0;
}
my $fh1=shift @ARGV;
my $fh2=shift @ARGV;
my $fh3=shift @ARGV;
open FH2,"<$fh2";
open FH1,"<$fh1";
my $minus;
while (<FH2>)
{
  chomp($_);
  $_ =~ s# ##g;  
  $minus->{$_}=1;
}
close FH2;
while (<FH1>)
{
  chomp($_);
  my @rec=split(/[\s]+/,$_);
  $rec[$fh3-1] =~ s# ##g;
  if (! exists($minus->{$rec[$fh3-1]}))
   {
   print $_."\n";
   }
   
}
close FH1;

