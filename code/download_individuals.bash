#!/bin/bash   

# To use:
# ./individuals.bash -c N
# 
# To separate out the mutation lists for each individual:
# step 0 - download each chromosome file and move the long names to a shorter name
#			e.g. ALL.chr1.phase3.......vcf.gz becomes ALL.chr1.individuals.vcf.gz
#

while getopts 'c:v' flag; do
  case "${flag}" in
    c) c="${OPTARG}" ;;
    v) verbose='true' ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done

dataset='20130502'
echo 'now processing chromosome '$c
dataloc='ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/release/'$dataset'/'
dir='../data/'$dataset'/'

mkdir $dir

### step 0
oldfile='ALL.chr'$c'.phase3_shapeit2_mvncall_integrated_v5a.'$dataset'.genotypes.vcf.gz'
echo 'fetching file from '$oldfile
wget -P $dir $dataloc$oldfile
newfile=$dir'ALL.chr'$c'.individuals.vcf.gz'
echo 'moving '$dir$oldfile' to '$newfile
mv $dir$oldfile $newfile

