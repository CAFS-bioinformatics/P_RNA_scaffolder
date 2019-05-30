#!/usr/bin/perl -w 
use strict;
if( @ARGV != 3) {
    print "Usage:  $0 both.nodes unique_map.intron.file default_gap_size\n";
    exit 0;
}

#CR848821.12_R	f	1	95891	CABZ01041119.1_F	f	2525	11178	0	0	0.00039619651347067	1.04285073676547e-05	0.000406625020838325	One
#	One

my $fh1=shift @ARGV;
my $fh2=shift @ARGV;
my $gap=shift @ARGV;

my @intron;
my $m=0;
open FH2,"<$fh2";
while (<FH2>)
{
  chomp($_);
  #SRR324684.17630829/1	3S33M9266N15M
  my @rec=split(/\s+/,$_);
  if ($rec[1] =~/([\d]+)N/)
  {
    $intron[$m++]=$1;
  }
}
close FH2;


  my @list = sort{$a<=>$b} @intron;
  my $count = @list;
  my $lower;
  if(($count%2)==1)
  {
	if (!exists $list[int(($count-1)/2)])
        {
               $list[int(($count-1)/2)]=0;
        }
        $lower= $list[int(($count-1)/2)];
  }
  elsif(($count%2)==0)
  {
        if (!exists $list[int(($count-1)/2)])
        {
               $list[int(($count-1)/2)]=0;
        }
        if (!exists $list[int(($count)/2)])
        {
               $list[int(($count)/2)]=0;
        }

        $lower= ($list[int(($count-1)/2)]+$list[int(($count)/2)])/2;
  }

#print "Start finding header.......\n";
my $next;
my $length;
my $next_info;
my $before;
my $read;

open FH1, "< $fh1";
while(<FH1>)
{
  chomp($_);
  my @rec=split(/\s+/,$_);
  $next->{$rec[0]}=$rec[1];
  $before->{$rec[1]}=$rec[0];
  $length->{$rec[0]}{$rec[1]}=$rec[3];
  $length->{$rec[1]}{$rec[0]}=$rec[3];
}
close FH1;
#my $real_header;
foreach my $key (keys %$next)
{
   if (!exists($before->{$key}) && !exists($read->{$key}))
   {
   print $key; 
   #   $real_header->{$key}=1;
    printnode ($key)
   }
}
#print "Finishing finding header.......\n";
my $temp;
sub printnode
{ 
  my ($key1)=@_; 
#  print $key1."(".$next_info->{$key1}{$next->{$key1}}.")->";
#  $mark->{$key1}=1;
  if (exists ($next->{$key1}) )
  {
     print "->";
     
     if (int($length->{$key1}{$next->{$key1}}) < $lower)
     {
       print "N(".($lower - int($length->{$key1}{$next->{$key1}})).")->";
     }
     else
     {
        print "N(".$gap.")->";
     }
     print $next->{$key1};
     return (printnode($next->{$key1})); 
  }
  elsif (!exists ($next->{$key1}))
  {
    if ($key1=~/([\S]+)\/r$/)
    {
    
      $read->{$1}=1;
    }
    else 
    {
      $temp=$key1."/r";
      $read->{$temp}=1;
    }
   #  print $key1."(".$next_info->{$key1}{$next->{$key1}}.")->";
     print "\n";
  }
} 

