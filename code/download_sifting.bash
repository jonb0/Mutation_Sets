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
echo 'now processing chromosome '$c
dataloc='ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/'$dataset'/supporting/functional_annotation/filtered/'
dir='../data/F'$dataset'/'
file='ALL.chr'$c'.phase3_shapeit2_mvncall_integrated_v5.20130502.sites.annotation.vcf.gz'
wget -P $dir $dataloc$file
newfile=$dir'ALL.chr'$c'.vcf.gz'
echo 'moving '$dir$file'to '$newfile
mv $dir$file $newfile
