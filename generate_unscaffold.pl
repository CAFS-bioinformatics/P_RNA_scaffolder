#!/usr/bin/perl
#mm_10008_m.0.17 32306003,32304536,32304385,32304049    32306103,32304612,32304439,32304090
#-1  18/0            AA033453
use strict;
if( @ARGV != 2 ) {
    print "Usage: $0 contig.fasta redundant.id\n";
    print "Destination: find the common dataset from the plus-file and minus-file\n";
    print "Note:This script can be used to identify cis- and trans-\n";
    exit 0;
}
my $fh1=shift @ARGV;

my $fh2=shift @ARGV;
use Bio::Seq;
use Bio::SeqIO;
use Bio::PrimarySeq;
my $in=Bio::SeqIO->new(-file=>"$fh1",'-format'=>'fasta');
my $seq=$in->next_seq();
my $id;
my $temp;
my $print;
open FH2, "<$fh2";
while (<FH2>)
{
 chomp($_);
 my @rec=split(/\t/,$_);
 $id->{$rec[0]}=1;
}
close FH2;
my $disp=$seq->display_id();
while ($seq)
{
 $disp=$seq->display_id();
 chomp($disp);
 if (!exists($id->{$disp}))
 {  
     print ">".$disp."\n";
     print $seq->seq()."\n";
 }
 $seq=$in->next_seq();
}

