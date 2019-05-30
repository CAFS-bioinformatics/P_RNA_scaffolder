#!/usr/local/bin/perl -w
if( @ARGV != 3 )
{
    print "Usage: perl $0  contigs.fa filter_F.sam filter_R.sam\n";
    exit 0;
}
my $fh1 = shift @ARGV;
my $fh2 = shift @ARGV;
my $fh3 = shift @ARGV;
open FH1,"<$fh1";
my $len;
while ($line = <FH1>)
{
  chomp $line;
  my @a = split / /, $line;
  if($a[0] =~ />/)
  {
    $a[0] =~s/\>//;
    $id = $a[0];
  }
  else
  {
    $len{$id}+=length$line;
  }
}
close FH1;
open FH2,"<$fh2";
while ($line = <FH2>)
{
my $sum=0;
chomp $line;
my @a = split / /, $line;
 $a[1]=~s/0/+/;
 $a[1]=~s/16/-/;
 $a[5]=~ s/[A-Z]$//;
 $a[5]=~ s/[A-Z]/\+/g;
  $length1{$a[0]} =length$a[9];
  my @cigar = split/\+/, $a[5];
  foreach $c (@cigar){
  $sum = $sum + $c;
  }
    $suma{$a[0]}=$a[3]+$sum;
    $a0{$a[0]}=$a[0];$a1{$a[0]}=$a[1];$a2{$a[0]}=$a[2];$a3{$a[0]}=$a[3];
  }
  close FH2;
    open FH3,"<$fh3";
   while ($line = <FH3>)
   {my $sum=0;
    chomp $line;
    my @b = split / /, $line;
    $b[1]=~s/0/+/;
     $b[1]=~s/16/-/;
      $b[5]=~ s/[A-Z]$//;
       $b[5]=~ s/[A-Z]/\+/g;
       $length2=length$b[9];
    $length2_1=$length1{$b[0]}+1;
    $length2_2=$length2+$length1{$b[0]};
    $readlength=$length1{$b[0]}+$length2;
    my @cigar = split/\+/, $b[5];
	  foreach $c (@cigar){
	    $sum = $sum + $c;
	     }
	       $sumb=$b[3]+$sum;
	       $p1=$length1{$b[0]}/$readlength;
	       $p2=$length2/$readlength;
print "$a0{$b[0]}\t1\t$length1{$b[0]}\t$length1{$b[0]}\t1\t$readlength\t$a2{$b[0]}\t$len{$a2{$b[0]}}\t$a3{$b[0]}\t$suma{$b[0]}\t$p1\t100\t$a1{$b[0]}\n";
print "$b[0]\t$length2_1\t$length2_2\t$length2\t1\t$readlength\t$b[2]\t$len{$b[2]}\t$b[3]\t$sumb\t$p2\t100\t$b[1]\n";
}
close FH3;
