#!/usr/local/bin/perl -w
if (@ARGV!=4)
{
  print "Usage: perl $0 samfile read_1.sam read_2.sam intron.txt\n";
  exit 0;
}
my $read="";
my $n=0;
my $fh1 = shift @ARGV;
my $fh2 = shift @ARGV;
my $fh3 = shift @ARGV;
my $fh4 = shift @ARGV;
open OUT1,">$fh2";
open OUT2,">$fh3";
open OUT3,">$fh4";
open FH1,"<$fh1";
while ($line = <FH1>)
{  
  if($line!~/\t\=\t/ && $line!~/\t\*\t/)
  {
  chomp $line;
  my @a = split/\t/, $line;
  if ($a[0]ne$read)
  {
    if($n==2)
    {
      my @b = split/\n/, $hash{$read};
      my @c = split/\t/, $b[0];
      my @d = split/\t/, $b[1];
      if ($c[2]ne$d[2])
      {
        if ($c[1]==65||$c[1]==97)
	{
	  $c[1]=0;
	  print OUT1 "@c\n";  
	  if ($c[5]=~ /N/)
	  {
	    print OUT3 "$c[0]\t$c[5]\n";
	  }
	}
        elsif ($c[1]==129||$c[1]==161)
	{
          $c[1]=16;
          print OUT2 "@c\n";
	  if ($c[5]=~ /N/)
	  {
	    print OUT3 "$c[0]\t$c[5]\n";
	  }
	}
        elsif ($c[1]==113||$c[1]==81)
	{
	  $c[1]=16;
	  print OUT1 "@c\n";
	  if ($c[5]=~ /N/)
	  {
	    print OUT3 "$c[0]\t$c[5]\n";
	  }
	}
	elsif ($c[1]==145||$c[1]==177)
	{
	  $c[1]=0;
	  print OUT2 "@c\n";
	  if ($c[5]=~ /N/)
	  {
	    print OUT3 "$c[0]\t$c[5]\n";
	  }
	}
        if ($d[1]==65||$d[1]==97)
	{
	  $d[1]=0;
	  print OUT1 "@d\n";  
	  if ($d[5]=~ /N/)
	  {
	    print OUT3 "$d[0]\t$d[5]\n";
	  }
	}
        elsif ($d[1]==129||$d[1]==161)
	{
          $d[1]=16;
          print OUT2 "@d\n";
	  if ($d[5]=~ /N/)
	  {
	    print OUT3 "$d[0]\t$d[5]\n";
	  }
	}
        elsif ($d[1]==113||$d[1]==81)
	{
	  $d[1]=16;
	  print OUT1 "@d\n";
	  if ($d[5]=~ /N/)
	  {
	    print OUT3 "$d[0]\t$d[5]\n";
	  }
	}
	elsif ($d[1]==145||$d[1]==177)
	{
	  $d[1]=0;
	  print OUT2 "@d\n";
	  if ($d[5]=~ /N/)
	  {
	    print OUT3 "$d[0]\t$d[5]\n";
	  }
	}
      }
      undef %hash;
    }
    $n=1;
    $read=$a[0];
    $hash{$a[0]}=$line;
  }
  else
  {
    $n=$n+1;
    $hash{$a[0]}.="\n".$line;
  }
  }
};
close FH1;
close OUT2;
close OUT3;
