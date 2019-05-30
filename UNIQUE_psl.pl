#!/usr/local/bin/perl -w
if( @ARGV != 6 ) {
    print "Usage: perl $0 -f1 read_1.psl -f2 read_2.psl -n 0.90 \n";
    exit 0;
}

use Getopt::Long;
Getopt::Long::GetOptions('f1=s'  => \$fh1,'f2=s'  => \$fh2,'n=s'  => \$n);
my $hash1;
my $hash2;
open FH1,"<$fh1";
while (<FH1>)
{
  chomp $_;
  my @a = split(/\t/,$_);
  if($a[0]/$a[10] >= $n && $a[10] != 0)
  {
    if(exists$hash1{$a[9]})
    {
      $hash1{$a[9]}="multiple";
    }
    else
    { 
      $hash1{$a[9]}=$a[13];
    }
  }
}
close FH1;
open FH2,"<$fh2";
while (<FH2>)
{
  chomp $_;
  my @a = split(/\t/,$_);
  if($a[0]/$a[10] >= $n && $a[10] != 0)
  {
   if(exists$hash2{$a[9]})
   {
     $hash2{$a[9]}="multiple";
   }
   else
   {
     $hash2{$a[9]}=$a[13];
   }
  }
}
close FH2;
foreach my $key ( keys(%hash1) )
{
  if($hash1{$key} eq "multiple") 
  {
     print $key."\n";
  }
  if (defined($hash2{$key}) && $hash1{$key} eq  $hash2{$key} )
  {
     print $key."\n";
  }
}
foreach my $key ( keys(%hash2) )
{
  if($hash2{$key} eq "multiple") 
  {
     print $key."\n";
  }
  if (defined($hash1{$key}) && $hash1{$key} eq  $hash2{$key} )
  {
     print $key."\n";
  }
}



