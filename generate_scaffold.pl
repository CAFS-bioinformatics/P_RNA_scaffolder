#!/usr/bin/perl
use strict;
if( @ARGV != 3 ) {   
    print "Usage: perl $0 sequence.fasta find-linker.result name\n";
    exit 0;
}
use Bio::Seq;
use Bio::SeqIO;
use Bio::PrimarySeq;

my $fh1=shift @ARGV;
my $fh2=shift @ARGV;
my $name=shift @ARGV;

my $in=Bio::SeqIO->new(-file=>"$fh1",'-format'=>'fasta');
my $seq=$in->next_seq();
my $string=$seq->seq();
my $SEQ;
my $disp=$seq->id();
while ($seq)
{
  $disp=$seq->id();
 # print $disp."\n";
  $string=$seq->seq();
  $SEQ->{$disp}=$string;
  $seq=$in->next_seq();
}
open FH2,"<$fh2";
my $j=1;
while (<FH2>)
{
  chomp($_);
 # r.contig1034758|utg71800031128571F_1_F->N(212)->r.contig1034757|utg71800031128561F_1_F->N(214)->r.contig1034756|utg71800031128551F_1_F
  my @rec=split(/\-\>/,$_);
  print ">".$name.$j. "\n";
  for (my $i=0;$i<=$#rec;$i++)
  {
    if ($rec[$i] =~ /^N\(([0-9]*)\)/)
    {
      my $null=$1;
      if ($null > 0)
      {
         for (my $n=1;$n<=$null;$n++)
	 {
             print "N";
	 }
      }
    }
    elsif ($rec[$i] =~/^([\S]+)\/r$/)
    {
        my  $tmp_string = reverse $SEQ->{$1};
        $tmp_string =~ tr/AaCcTtGg/TtGgAaCc/;
	print $tmp_string;
    }
    elsif ($rec[$i] =~/^([\S]+)$/)
    {
        print $SEQ->{$rec[$i]};
    }
  }
  print "\n";
  $j=$j + 1;
}  
close FH2;
