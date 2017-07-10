#!/bin/bash

ananke import_from_dada2 -i sequence_data/dada2_omega1e2.csv -m sequence_data/METADATA_B.txt -f seq.unique.fasta -t collection_day -o Stool_Ananke.h5
ananke cluster -i Stool_Ananke.h5 -n 4 -u 1 -l 0.01 -s 0.01 -d sts

#Optional: classify the reads with RDP via QIIME
assign_taxonomy.py -m rdp -i seq.unique.fasta -o assigned_taxonomy
#Remove the size labels
sed -i 's/;size=[0-9]*;//g' assigned_taxonomy/seq.unique_tax_assignments.txt
ananke add taxonomy -i Stool_Ananke.h5 -d assigned_taxonomy/seq.unique_tax_assignments.txt

#Optional: cluster the reads with UPARSE/USEARCH
usearch -sortbysize seq.unique.fasta -output seq.unique.sorted.fasta -minsize 2
usearch -cluster_otus seq.unique.sorted.fasta -otus otus.fasta -otu_radius_pct 3
usearch -usearch_global seq.unique.fasta -db otus.fasta -strand both -id 0.97 -uc map.uc -threads 6
#Script found at: https://github.com/neufeld/MESaS
mesas-uc2clust -t 6 map.uc seq_otus.txt
sed -i 's/;size=[0-9]*;//g' seq_otus.txt
awk 'BEGIN{i=0;}{print i "\t" $0; i+=1;}' seq_otus.txt > seq_renumbered.txt
ananke add sequence_clusters -i Stool_Ananke.h5 -d seq_renumbered.txt
