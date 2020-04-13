#!/bin/sh
#  130420
#  J Baxter
#  preprocessing of fasta files: count, split, align, concatenate

#read file from argument
INPUTFASTA="$1"

#number of sequences
NUMSEQ=$(grep -c '^>' $INPUTFASTA)
echo "$NUMSEQ sequences in file"

#prepare workind directory - currently cannot operate if directories already present
#maybe look to test whether $dirname exists - if not continue, if so add suffix integer
sysdate=$(date +'%d%b%y')
dirname=$(echo "splitalign$sysdate")
mkdir $dirname
mkdir $dirname/splits
mkdir $dirname/aligned_splits
mkdir $dirname/result

cp $INPUTFASTA ./$dirname
cd ./$dirname

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
