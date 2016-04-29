#!/bin/bash   
# To use:
# ./individuals.bash -c N
# 
# To separate out the mutation lists for each individual:
# step 0 - download each chromosome file and move the long names to a shorter name
#			e.g. ALL.chr1.phase3.......vcf.gz becomes ALL.chr1.individuals.vcf.gz
#
# step 1 - gunzip files
#
# step 2 - make new directories
#
# step 3 - run the oneliner grep -ve.... in 100 person batches, making sure the
#			chromosome number and file name are set.
#			This creates files of line numbers where individuals have mutations
#			on both alleles, corresponding to an rs number.
# 			nb - I've tried doing it in 1 go, it was going to take a millennium
#			nb2 - it should take .5-2 hours to run each 100, depending on the machine
#			and size of the chromosome
#
# step 4 - take the line numbers with mutations from the chrA.p files and rename them
#			into chrA.HGID in the chrAn directory. rm the chrA.p files that you don't 
# 			need anymore (they are really big)
# 
# step 5 - rm the unzipped (really large) file

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
newfile=$dir'ALL.chr'$c'.individuals.vcf.gz'

### step 1
echo 'unzipping '$newfile
time gunzip $newfile
unzipped=${newfile%.*z}
echo 'rosa1', $unzipped
awk 'NR == 253  {print; exit}' $unzipped > columns.txt

### step 2

pdir=$dir'chr'$c'p/'
ndir=$dir'chr'$c'n/'

mkdir $pdir
mkdir $ndir

echo 'rosa2'

### step 3
step=100
for j in {0..24}
do
	start=$(($j*$step + 10))
        finish=$(((($j + 1))*$step + 9))
	echo 'reading individuals '$start'-'$finish' from '$unzipped
	time grep -ve "#" $unzipped | awk -v c=$c -v start=$start -v finish=$finish -v dir=$dir '{for(i=start;i<=finish;i++) {name=dir"chr"c"p/chr"c".p"i-9;print $i"	"$3 > name}}'
done
echo 'reading individuals 2510 - 2513 from '$unzipped
time grep -ve "#" $unzipped | awk -v c=$c -v dir=$dir '{for(i=2510;i<=2513;i++) {name=dir"chr"c"p/chr"c".p"i-9;print $i"   "$3 > name}}'



#### step 4
columfile='columns.txt.'$c
time for i in {1..2504}
do
	col=$(($i + 9))
	name=$(cut -f $col $columfile)
	oldfile=$pdir'chr'$c'.p'$i
	newfile=$ndir'chr'$c'.'$name
	echo 'moving '$oldfile' to '$newfile
	time cat $oldfile | awk -F "|" '$1>=1 && $2>=1 {print $2}' > tmp.file.$c
  	time cat tmp.file.$c | awk '{print $NF}' > $newfile
	#rm $oldfile
done

rm tmp.file.$c
### step 5
rm $unzipped
