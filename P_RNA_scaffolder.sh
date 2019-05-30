#!/bin/bash
#!/bin/sh
output=./
intron=100000
frequency=2
N=100
pid=0.90
threads=5
blat=yes
species=yes
while getopts ":d:l:p:n:e:f:i:j:o:F:R:t:b:s" opt; do
  case $opt in
    d)
      directory=$OPTARG
      vardir=1
      ;;
    o)
      output=$OPTARG
      ;;
    p)
      pid=$OPTARG
      ;;
    e)
      intron=$OPTARG
      ;;
    f)
      frequency=$OPTARG
      ;;
    n)
      N=$OPTARG
      ;;
    t)
      threads=$OPTARG
      ;;
    b)
      blat=$OPTARG
      ;;
    i)
      inputfile=$OPTARG
      varsam=1
      ;;
    j)
      contig=$OPTARG
      varfasta=1
      ;;
    F)
      fastqF=$OPTARG
      varfqF=1
      ;;
    R)
      fastqR=$OPTARG
      varfqR=1
      ;;
    s)
      species=$OPTARG
      ;; 
    ?)

      echo "Usage: sh `basename $0` -d Program_DIR -i inputfile.sam -j contig.fasta -F read_1.fastq -R reads_2.fastq -s yes";
        echo "";
        echo "Input options";
        echo "     -d           the installing direcotry of P_RNA_scaffolder           [        mandatory ]";
        echo "     -i           SAM file of RNA-seq alignments to contigs with hisat   [        mandatory ]";
        echo "     -j           Pre-assembled contig FASTA file                        [        mandatory ]";
        echo "     -F           FASTQ file of left reads                               [        mandatory ]";
        echo "     -R           FASTQ file of right reads                              [        mandatory ]";
        echo "";
	echo "Output options";
        echo "     -o           write all output files to this directory               [ default:      ./ ]"; 
        echo "";
        echo "Species options"
        echo "     -s           the target species is Eukaryote or Prokaryote          [default:      yes ]";
        echo "                  (1) yes represents that the target species is Eukaryote. ";
        echo "                  (2) no represents that the target species is Prokaryote";
        echo "";
	echo "Two modes selection options";
        echo "     -b            re-align filtered RNA-seq reads to contigs with BLAT  [ default:     yes ]";
        echo "                   (1) If yes, perform the 'accurate' mode using BLAT to further filter      ";
	echo "                   out reads. The 'accurate' scaffolding has higher accuracy and longer      ";
	echo "                   running time than the 'fast' mode.";
        echo "                   (2) If no, perform the 'fast' mode without BLAT re-alignment and this mode";
	echo "                   is faster than the 'accurate' mode with less accuracy. ";
	echo "     -p            BLAT alignment identity cutoff                        [ default:    0.90 ]";
        echo "     -t            number of threads used in BLAT re-alignment           [ default:       5 ]";	
        echo "";
        echo "Scaffolding options";
        echo "     -e            the maximal allowed intron length                     [ default:  100000 ]";
        echo "     -f            the minimal supporting RNA-seq pair number            [ default:       2 ]";
        echo "     -n            the number of inserted N to indicate a gap            [ default:  100 bp ]";
        echo "";        
      
      exit 1
      ;;
      :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [[ $vardir -eq 1 ]] && [[ $varsam -eq 1 ]] && [[ $varfasta -eq 1 ]] && [[ $varfqF -eq 1 ]] && [[ $varfqR -eq 1 ]] && [[ $blat = no ]]; then

        if [ ! -d $output ] ; then
	mkdir "$output"	
	fi
        `perl $directory/UNIQUE_sam_intron.pl $inputfile $output/F.sam $output/R.sam $output/intron.txt`;
	`perl $directory/guider.pl $contig $output/F.sam $output/R.sam  > $output/guider`;
	`$directory/link_block $output/guider $output/linker $intron`;
	`sort -k1,1 -k2,2n -k27,27n -k16,16nr $output/linker > $output/sort.linker`;
	`$directory/delete_linker $output/sort.linker $output/retained.linker`;
	`$directory/delete_same_fragment $output/retained.linker $output/linker.dif`;   
	`$directory/exon_length $output/linker.dif $output/linker.length`;
	`$directory/convert_linker $output/linker.length $output/linker.convert`;
	`sort -k2,2 -k3,3 -k4,4nr $output/linker.convert > $output/linker.select`;
	`cut -f 2-4 $output/linker.select |sort -k1,1 -k2,2 > $output/connections`;
	`$directory/count_connection_frequency $output/connections $output/connections.frequency`;
	`$directory/find_reliable_connection $output/connections.frequency $output/reliable.connections $frequency`;
	`sort -k1,1 -k3,3nr $output/reliable.connections > $output/sort.reliable.connection`;
	`$directory/find_end_node $output/sort.reliable.connection $output/end.node`;
	`sort -k2,2 -k3,3nr $output/end.node > $output/sort.end.node`;
	`$directory/find_start_node $output/sort.end.node $output/start.node`;
	`$directory/select_nodes $output/start.node $output/both.nodes`;
	`perl $directory/form_path.pl $output/both.nodes $output/intron.txt $N > $output/both.path`;
        `sed 's/->/\n/g' $output/both.path |sed 's/\/r//g' |grep -v "N(" |sort -u > $output/scaffolded.fragment.id`;
        perl $directory/generate_scaffold.pl $contig $output/both.path P_RNA_scaffold_ > $output/scaffold.fasta & perl $directory/generate_unscaffold.pl $contig $output/scaffolded.fragment.id  > $output/unscaffold.fasta
        wait
        `cat $output/scaffold.fasta $output/unscaffold.fasta >$output/P_RNA_scaffold.fasta`;

exit 1

elif [[ $vardir -eq 1 ]] && [[ $varsam -eq 1 ]] && [[ $varfasta -eq 1 ]] && [[ $varfqF -eq 1 ]] && [[ $varfqR -eq 1 ]] && [[ $blat = yes ]]; then

        if [ ! -d $output ] ; then
        mkdir "$output"
        fi
        `perl $directory/UNIQUE_sam_intron.pl $inputfile $output/F.sam $output/R.sam $output/intron.txt`;
        perl $directory/sam2fa.pl $output/F.sam $fastqF $output/F.fa & perl $directory/sam2fa.pl $output/R.sam $fastqR $output/R.fa
        wait
        lineF=(`wc $output/F.fa`)
        splitlineF=`expr $lineF / 2 / $threads \* 2 + 2`
        `split -d -l $splitlineF $output/F.fa $output/F_`
        for  FILE in $output/F_*
        do
          $directory/blat $contig $FILE $FILE.psl -noHead 1>>$output/blatF_log 2>>$output/blatF_error &
        done
        wait
        lineR=(`wc $output/R.fa`)
        splitlineR=`expr $lineR / 2 / $threads \* 2 + 2`
        `split -d -l $splitlineR $output/R.fa $output/R_`
        for  FILE in $output/R_*
        do
          $directory/blat $contig $FILE $FILE.psl -noHead 1>>$output/blatR_log 2>>$output/blatR_error &
        done
        wait
        lineN=(`ls $output/R_*.psl | wc`)
        a=(`ls $output/F_*.psl`)
        b=(`ls $output/R_*.psl`)
        for (( i=0; i<$lineN; i++))
        do
          perl $directory/UNIQUE_psl.pl -f1 ${a[$i]} -f2 ${b[$i]} -n $pid >$output/blat-$i.filter.id &
        done
        wait
        `cat $output/blat-*.filter.id |sort -u >$output/blat_filter.id`
        if [[ $species = yes ]] ; then        
         `perl $directory/count-match.pl $output/F.sam $output/R.sam |sort -u >>$output/blat_filter.id`  
        fi
        `rm $output/blat-*.filter.id $output/F_* $output/R_*`
        `perl $directory/filter-out.pl $output/F.sam $output/blat_filter.id 1 >$output/filter_F.sam & perl $directory/filter-out.pl $output/R.sam $output/blat_filter.id 1 >$output/filter_R.sam`
	wait
        `perl $directory/guider.pl $contig $output/filter_F.sam $output/filter_R.sam  > $output/guider`;
        `$directory/link_block $output/guider $output/linker $intron`;
        `sort -k1,1 -k2,2n -k27,27n -k16,16nr $output/linker > $output/sort.linker`;
        `$directory/delete_linker $output/sort.linker $output/retained.linker`;
        `$directory/delete_same_fragment $output/retained.linker $output/linker.dif`;
        `$directory/exon_length $output/linker.dif $output/linker.length`;
        `$directory/convert_linker $output/linker.length $output/linker.convert`;
        `sort -k2,2 -k3,3 -k4,4nr $output/linker.convert > $output/linker.select`;
        `cut -f 2-4 $output/linker.select |sort -k1,1 -k2,2 > $output/connections`;
        `$directory/count_connection_frequency $output/connections $output/connections.frequency`;
        `$directory/find_reliable_connection $output/connections.frequency $output/reliable.connections $frequency`;
        `sort -k1,1 -k3,3nr $output/reliable.connections > $output/sort.reliable.connection`;
        `$directory/find_end_node $output/sort.reliable.connection $output/start.node`;
        `$directory/select_nodes $output/start.node $output/both.nodes`;
        `perl $directory/form_path.pl $output/both.nodes $output/intron.txt $N > $output/both.path`;
        `sed 's/->/\n/g' $output/both.path |sed 's/\/r//g' |grep -v "N(" |sort -u > $output/scaffolded.fragment.id`;
        perl $directory/generate_scaffold.pl $contig $output/both.path P_RNA_scaffold_ > $output/scaffold.fasta & perl $directory/generate_unscaffold.pl $contig $output/scaffolded.fragment.id  > $output/unscaffold.fasta
        wait
        `cat $output/scaffold.fasta $output/unscaffold.fasta >$output/P_RNA_scaffold.fasta`;

exit 1

else
        echo "Usage: sh `basename $0` -d Program_DIR -i inputfile.sam -j contig.fasta -F read_1.fastq -R read_2.fastq -s yes";
        echo "";
        echo "Input options";
        echo "     -d           the installing direcotry of P_RNA_scaffolder           [        mandatory ]";
        echo "     -i           SAM file of RNA-seq alignments to contigs with hisat   [        mandatory ]";
        echo "     -j           Pre-assembled contig FASTA file                        [        mandatory ]";
        echo "     -F           FASTQ file of left reads                               [        mandatory ]";
        echo "     -R           FASTQ file of right reads                              [        mandatory ]";
        echo "";
	echo "Output options";
        echo "     -o            write all output files to this directory              [ default:      ./ ]"; 
        echo "";
        echo "Species options"
        echo "     -s           the target species is Eukaryote or Prokaryote          [default:      yes ]";
        echo "                  (1) yes represents that the target species is Eukaryote. ";
        echo "                  (2) no represents that the target species is Prokaryote";
        echo "";
	echo "Two modes selection options";
        echo "     -b            re-align filtered RNA-seq reads to contigs with BLAT  [ default:     yes ]";
        echo "                   (1) If yes, perform the 'accurate' mode using BLAT to further filter      ";
	echo "                   out reads. The 'accurate' scaffolding has higher accuracy and longer      ";
	echo "                   running time than the 'fast' mode.";
        echo "                   (2) If no, perform the 'fast' mode without BLAT re-alignment and this mode";
	echo "                   is faster than the 'accurate' mode with less accuracy. ";
	echo "     -p            BLAT alignment identity cutoff                        [ default:    0.90 ]";
        echo "     -t            number of threads used in BLAT re-alignment           [ default:       5 ]";	
        echo "";
        echo "Scaffolding options";
        echo "     -e            the maximal allowed intron length                     [ default:  100000 ]";
        echo "     -f            the minimal supporting RNA-seq pair number            [ default:       2 ]";
        echo "     -n            the number of inserted N to indicate a gap            [ default:  100 bp ]";
        echo "";        

        exit 1

fi

