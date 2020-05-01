#!/bin/sh
#  130420
#  J Baxter
#  preprocessing of fasta files: count, split, align, concatenate
#  010520 JB create new directory with counter if one already exists

#read file from argument
INPUTFASTA="$1"

#number of sequences
NUMSEQ=$(grep -c '^>' $INPUTFASTA)
echo "$NUMSEQ sequences in file"

#prepare working directory
sysdate=$(date +'%d%b%y')
propname=$(echo "splitalign_${sysdate}")

#is dirname already a directory?
if [ -d "${propname}" ]
then
  counter=1
  newname=$(echo "splitalign_${sysdate}_${counter}")
  while [ -d "${newname}" ]
  do
    counter=$((counter+1))
    newname=$(echo "splitalign_${sysdate}_${counter}")
  done
  dirname=$(echo "splitalign_${sysdate}_${counter}")
else
  dirname=$(echo "${propname}")
fi

mkdir $dirname
cp $INPUTFASTA ./$dirname
cd ./$dirname

for subdir in splits aligned_splits reults
do
  mkdir "$subdir"
done

#set split level
if [ $NUMSEQ -le 100 ]
then
    echo 'no splits required'
    SPLITLEVEL=$NUMSEQ
elif [ $NUMSEQ -gt 100 -a $NUMSEQ -lt 300 ]
then
    echo 'splitting fasta into 3'
    SPLITLEVEL=$( $NUMSEQ / 3 )
else
    echo 'splitting fasta into files of 100 sequences'
    SPLITLEVEL=100
fi

#split
awk -vdenom="$SPLITLEVEL" 'BEGIN {n_seq=0;} /^>/ {if(n_seq%denom==0){file=sprintf("splits/output_split_%d.fas",n_seq);} print >> file; n_seq++; next;} {print >> file; }' < $INPUTFASTA

#align sequences in parallel
cd ./splits

CHOSENALGO="$2"
if [ "$CHOSENALGO" = "muscle" ]
then
    parallel 'muscle -in {} -out ../aligned_splits/{.}.fas' ::: *.fas
elif [ "$CHOSENALGO" = "mafft-globalp" ]
then
    parallel 'mafft --maxiterate 1000 --globalpair {} > ../aligned_splits/{.}.fas' ::: *.fas
elif [ "$CHOSENALGO" = "mafft-quick" ]
then
    parallel 'mafft --retree 2 {} > ../aligned_splits/{.}.fas' ::: *.fas
elif [ "$CHOSENALGO" = "mafft" ]
then
    parallel 'mafft --auto {} > ../aligned_splits/{.}.fas' ::: *.fas
else
    echo "no valid input detected. refering to default alignment algorithm, muscle."
    parallel 'muscle -in {} -out ../aligned_splits/{.}.fas' ::: *.fas
fi


#rejoin fasta files using cat
cd ../aligned_splits
cat *.fas > ../result/concatenated_aligned.fas

echo "concatenated aligned fasta saved in results directory"
echo "done"
