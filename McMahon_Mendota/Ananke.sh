#!/bin/bash

ananke import_from_dada2 -i sequence_data/dada2_omega1e2.csv -m sequence_data/METADATA_modified.txt -f seq.unique.fasta -t time_points -o Mendota_Ananke.h5

ananke cluster -i Mendota_Ananke.h5 -l 0.01 -u 1 -s 0.01 -d sts -n 4

#Optional: use the TaxAss.sh script to generate the taxonomic classifications
#Run the TaxAss.sh to create them on your own, or just use the version that
#should be in the GitHub
ananke add taxonomy -i Mendota_Ananke.h5 -d TaxAss/taxonomy.txt

#Optional: cluster the reads with UPARSE/USEARCH
usearch -sortbysize seq.unique.fasta -output seq.unique.sorted.fasta -minsize 2
usearch -cluster_otus seq.unique.sorted.fasta -otus otus.fasta -otu_radius_pct 3
usearch -usearch_global seq.unique.fasta -db otus.fasta -strand both -id 0.97 -uc map.uc -threads 6
#Script found at: https://github.com/neufeld/MESaS
mesas-uc2clust -t 6 map.uc seq_otus.txt
sed -i 's/;size=[0-9]*//g' seq_otus.txt
awk 'BEGIN{i=0;}{print i "\t" $0; i+=1;}' seq_otus.txt > seq_renumbered.txt
ananke add sequence_clusters -i Mendota_Ananke.h5 -d seq_renumbered.txt
