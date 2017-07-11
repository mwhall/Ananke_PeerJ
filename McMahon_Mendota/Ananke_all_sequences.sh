#!/bin/bash

#This script runs Ananke using ALL sequences, without prefiltering with DADA2
#Presumes that you have run fetchData.sh

#First, concatenate the sequence files together
cd sequence_data
for fname in `ls *.fastq.gz`; do
    gunzip ${fname}
    bname=`basename -s .fastq.gz ${fname}`
    awk -v samp=${bname} 'BEGIN{i=0;}{print ">" samp "_" i; i+=1; getline; print; getline; getline;}' ${bname}.fastq >> seq.fasta
    gzip ${bname}.fastq
done

cd ..

#Tabulate the sequences into time series
ananke tabulate -i sequence_data/seq.fasta -o Mendota_Ananke_full.h5 -f seq.unique.full.fasta -m sequence_data/METADATA_modified.txt -t time_points

#Save some space, gzip this FASTA file
gzip sequence_data/seq.fasta

#Use an abundance filter
ananke filter -i Mendota_Ananke_full.h5 -o Mendota_Ananke_full_filtered.h5 -f abundance -t 100

ananke cluster -i Mendota_Ananke_full_filtered.h5 -l 0.01 -u 1 -s 0.01 -d sts -n 6

#Filter the unique sequence file for quicker clustering/taxonomic classification
awk '{split($0,x,"="); sub(/;/,"",x[2]); if (int(x[2]) >= 100) {print; getline; print;} else {getline;}}' seq.unique.full.fasta > seq.unique.full.min100.fasta

#Optional: cluster the reads with UPARSE/USEARCH
usearch -sortbysize seq.unique.full.min100.fasta -output seq.unique.sorted.fasta -minsize 2
usearch -cluster_otus seq.unique.sorted.fasta -otus otus.fasta -otu_radius_pct 3
usearch -usearch_global seq.unique.full.min100.fasta -db otus.fasta -strand both -id 0.97 -uc map.uc -threads 6
#Script found at: https://github.com/neufeld/MESaS
python2 mesas-uc2clust -t 6 map.uc seq_otus.txt
sed -i 's/;size=[0-9]*;//g' seq_otus.txt
awk 'BEGIN{i=0;}{print i "\t" $0; i+=1;}' seq_otus.txt > seq_renumbered.txt
ananke add sequence_clusters -i Mendota_Ananke_full_filtered.h5 -d seq_renumbered.txt

#Optional: Add taxonomy information
#Edit TaxAss.sh for the full run to create taxonomy_full.txt from scratch, if desired
#Note that taxonomy.txt and taxonomy_full.txt should be in the GitHub
ananke add taxonomy -i Mendota_Ananke_full_filtered.h5 -d TaxAss/taxonomy_full.txt
