#!/bin/sh
# count how many files present
ls -1 | wc -l

# print filenames that are not duplicated
ls -1 | sed 's/\.RELAX\.json$//' | sort | uniq -c | awk '$1 == 1{print $2}'

# number of sequences in a .fasta file
grep ">" file.fasta | wc -l
# and in a loop...
for FILE in *.fasta; do grep ">" $FILE | wc -l; done
