#!/bin/bash   

# This script runs on the output of the VEP which includes the sift scores.
# For each chromosome, it moves and unzips the files.
# Then taking only the lines with sift scores, it records the line number 
# (minus the header) it came from.
# It looks up the ENSEMBL and HGNC gene cataplgues corresponding to each rs number
# using symbol_lookup.py. (optional)
# Then it combines all the columns into 
# line number, rs number, ENSEMBL ID, (HGNC ID), sift score, and phenotype score.

while getopts 'c:v' flag; do
  case "${flag}" in
    c) c="${OPTARG}" ;;
    v) verbose='true' ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

dataset='20130502'
dir='../data/F'$dataset'/'
	
	newfile=$dir'ALL.chr'$c'.vcf.gz'
	echo 'unzipping '$newfile
	gunzip $newfile
	unzipped=${newfile%.*z}
	echo 'unziped file:', $unzipped
	siftfile=$dir'SIFT.chr'$c'.vcf'
	header=$(head -n 1000 $unzipped | grep "#" | wc -l)
	echo 'taking columns from '$unzipped
	grep -n "deleterious\|tolerated" $unzipped | grep "rs" > $siftfile
	lines=$dir'line.txt'
	ids=$dir'id.txt'
	info=$dir'info.txt'
	sifts=$dir'sift.txt'
	awk '{print $1}' $siftfile | awk -F ":" '{print $1-'$header'}' > $lines #.txt
	awk '{print $3}' $siftfile > $ids #.txt
	awk '{print $8}' $siftfile > $info #.txt
	awk -F "|" '{print $5"\t"$17"\t"$18}' $info |\
		sed 's/(/\t/g' | sed 's/)//g' > $sifts

	final=$dir'sifted.SIFT.chr'$c'.txt'
	pr -m -t -s\  $lines $ids $sifts | gawk '{print $1,$2,$3,$5,$7}' > $final
	
	echo 'line, id, ENSG id, SIFT, and phenotype printed to '$final
	rm $siftfile
	rm $lines
	rm $ids
	rm $info
	rm $sifts
	

