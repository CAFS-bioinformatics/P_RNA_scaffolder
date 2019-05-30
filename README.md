<b>DESCRIPTION</b><p>
   P_RNA_scaffolder is a genome scaffolding tool with paired-end RNA-seq reads from studied species. Since the nucleotide sequences are not conserved across species, P_RNA_scaffolder does not support using paired-end RNA-seq from close speciess to scaffold the genome of studied species. The paired-end RNA-seq reads could be downloaed from public read archive database (for instance, NCBI SRA database) or be your own data. The paired-end reads are aligned to contigs using HISAT2 or BWA firstly and then BLAT. The SAM alignment files by HISAT2 or BWA are used as the input files of P_RNA_scaffolder. P_RNA_scaffolder searches "guide" pairs, two reads of which were mapped to two different contigs. Then the "guide" pairs orient and order the contigs into longer scaffolds.<p> 
<b>SYSTEM REQUIREMENTS</b><p>
(1)The software, written with Shell script, consists of C++ programs and Perl programs. The C programs have been precompiled and therefore could be directly executed. To run Perl program, perl and Bioperl modules should be installed on the system. 
(2)The program requires SAM files as input file. HISAT2 or BWA should be installed on the system.<p>
(3)P_RNA_scaffolder has been tested and is supported on Linux.<p>
<b>INPUT FILES</b><p>
(1)The SAM files are necessary for scaffolding. In eukaryotes, the SAM file was generated using HISAT2 program. In prokaryotes, the paired-end RNA-seq reads were aligned to the contigs using BWA program. <p>
(i)Take human contigs and RNA-seq reads as an eukaryote example. The alignment of RNA-seq reads could be performed as follows: <p>
hisat2-build contigs.fa human_hisat <p>
hisat2 -x human_hisat -1 read_1.fq -2 read_2.fq -k 3 -p 10 --pen-noncansplice 1000000 -S input.sam <p>
where read_1.fq and read_2.fq are the fastq files of two ends of RNA-seq reads. <p>
-k 3 means report up to 3 alignments per read. <p>
-p 10 means using 10 threads to align reads. <p>
--pen-noncansplice 1000000 means high penalty for a non-canonical splice site. <p>
-S input.sam means that the alignments of all reads were stored in the file of 'input.sam'.<p> 

(ii)Take E.coli contigs and RNA-seq reads as a prokaryote example. The alignment of RNA-seq reads could be performed as follows: <p>
bwa index -a is contigs.fa <p>
bwa mem -t 10 contigs.fa read_1.fq read_2.fq >input.sam <p>

where read_1.fq and read_2.fq are the fastq files of two ends of RNA-seq reads. <p>
-t 10 means using 10 threads to align reads. <p>
input.sam means that the alignments of all reads were stored in the file of 'input.sam'. <p>

(2)The contig file is also required and should be fasta format, consistent with the subject sequences when alignment. <p>

<b>COMMANDS AND OPTIONS</b><p>
   P_RNA_scaffolder is run via the shell script: P_RNA_scaffolder.sh found in the base installation directory.<p>

   Usage info is as follows:<p>
sh P_RNA_scaffolder.sh -d Program_dir -i input.sam -j contig.fa -F read_1.fa -R read_2.fq

Input options <p>
     -d           the installing direcotry of P_RNA_scaffolder           [        mandatory ] <p>
     -i           SAM file of RNA-seq alignments to contigs with hisat   [        mandatory ] <p>
     -j           Pre-assembled contig FASTA file                        [        mandatory ] <p>
     -F           FASTQ file of left reads                               [        mandatory ] <p>
     -R           FASTQ file of right reads                              [        mandatory ] <p>

Output options <p>
     -o            write all output files to this directory              [ default:      ./ ] <p>

Species options <p>
     -s           the target species is Eukaryote or Prokaryote          [default:      yes ] <p>
                  (1) yes represents that the target species is Eukaryote. <p>
                  (2) no represents that the target species is Prokaryote. <p>

Two modes selection options <p>
     -b            re-align filtered RNA-seq reads to contigs with BLAT  [ default:     yes ] <p>
                   (1) If yes, perform the 'accurate' mode using BLAT to further filter <p>
                   out reads. The 'accurate' scaffolding has higher accuracy and longer <p>
                   running time than the 'fast' mode. <p>
                   (2) If no, perform the 'fast' mode without BLAT re-alignment and this mode <p>
                   is faster than the 'accurate' mode with less accuracy. <p>
     -p            BLAT alignment identity cutoff                        [ default:    0.90 ] <p>
     -t            number of threads used in BLAT re-alignment           [ default:       5 ] <p>

Scaffolding options <p>
     -e            the maximal allowed intron length                     [ default:  100000 ] <p>
                   For genomes of different size, the maximal allowed intron length is <p>
                   different. For instance, in human, the maximal allowed intron length is  <p>
                   set as 100000 while in C.elegans, it is set as 15000. <p> 
     -f            the minimal supporting RNA-seq pair number            [ default:       2 ] <p>
     -n            the number of inserted N to indicate a gap            [ default:  100 bp ] <p>
<b>OUTPUT FILES</b><p>
   When P_RNA_scaffolder completes, it will create a P_RNA_scaffolder.fasta output file in the output_dir/ output directory.  <p>
<b>SPEED</b><p>
   P_RNA_scaffolder spent about 195 minutes in scaffolding human genome contigs with a SAM file generated from alignment of 113.8 millions of RNA-seq pairs. <p>
