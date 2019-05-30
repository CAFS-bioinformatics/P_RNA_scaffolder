#!usr/local/bin/perl -w
use strict;
if( @ARGV != 3 )
{
    print "Usage: perl $0  sam-file fastq-file fasta-output-file\n";
    exit 0;
}
my $fh1 = shift @ARGV;
my $fh2 = shift @ARGV;
my $fh3 = shift @ARGV;
open OUT1,">$fh3";
open FH1,"<$fh1";
my $id ="";
my %seq;
open FH1,"<$fh1";
while (my $line = <FH1>)
{
  chomp $line;
  my @a = split / /,$line;
  if($a[0]ne$id)
  {
    $seq{$a[0]}=1;
  }
  $id=$a[0];
}
close FH1;

open FH2,"<$fh2";
while (<FH2>)
{
  my @temp;
  chomp($temp[0] = $_);		# First line is an id.
  chomp($temp[1] = <FH2>);	# Second line is a sequence.
  chomp($temp[2] = <FH2>);	# Third line is an id.
  chomp($temp[3] = <FH2>);	# Fourth line is quality.
  my @aa = split / /,$temp[0];
  my @a = split /\t/,$aa[0];
  $id =$a[0];
  $id =~ s/\@//g;
  $id =~ s/\/1$//g;
  $id =~ s/\/2$//g;
  $id =~ s/\/F$//g;
  $id =~ s/\/R$//g;
  if (exists $seq{$id})
  {
    print OUT1 ">".$id."\n".$temp[1]."\n";
  }
  #print"$id\n$seq{$id}\n";
}
close FH2;
close OUT1;
