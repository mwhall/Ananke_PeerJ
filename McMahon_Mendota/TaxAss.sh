#!/bin/bash

#Before running, ensure the TaxAss/FreshTrain taxa-scripts is in your PATH!
#i.e., export PATH=/path/to/taxa-scripts:$PATH

export PATH=/home/mwhall/Software/TaxAss/tax-scripts/:$PATH
cd TaxAss
gunzip *.gz
#cp ../seq.unique.fasta otus.fasta
#For the full sequence run:
cp ../seq.unique.full.min100.fasta otus.fasta
sed -i 's/;size=[0-9]*;//g' otus.fasta
makeblastdb -dbtype nucl -in custom.fasta -input_type fasta -parse_seqids -out custom.db
blastn -query otus.fasta -task megablast -db custom.db -out otus.custom.blast -outfmt 11 -max_target_seqs 5
blast_formatter -archive otus.custom.blast -outfmt "6 qseqid pident length qlen qstart qend" -out otus.custom.blast.table
Rscript calc_full_length_pident.R otus.custom.blast.table otus.custom.blast.table.modified
Rscript filter_seqIDs_by_pident.R otus.custom.blast.table.modified ids.above.98 98 TRUE
Rscript filter_seqIDs_by_pident.R otus.custom.blast.table.modified ids.below.98 98 FALSE
python find_seqIDs_blast_removed.py otus.fasta otus.custom.blast.table.modified ids.missing
cat ids.below.98 ids.missing > ids.below.98.all
python create_fastas_given_seqIDs.py ids.above.98 otus.fasta otus.above.98.fasta
python create_fastas_given_seqIDs.py ids.below.98.all otus.fasta otus.below.98.fasta
mothur "#classify.seqs(fasta=otus.above.98.fasta, template=custom.fasta,  taxonomy=custom.taxonomy, method=wang, probs=T, processors=2, cutoff=0)"
mothur "#classify.seqs(fasta=otus.below.98.fasta, template=general.fasta,  taxonomy=general.taxonomy, method=wang, probs=T, processors=2, cutoff=0)"
cat otus.above.98.custom.wang.taxonomy otus.below.98.general.wang.taxonomy > otus.98.taxonomy
mothur "#classify.seqs(fasta=otus.fasta, template=general.fasta, taxonomy=general.taxonomy, method=wang, probs=T, processors=2, cutoff=0)"
cat otus.general.wang.taxonomy > otus.general.taxonomy
sed 's/[[:blank:]]/\;/' <otus.98.taxonomy >otus.98.taxonomy.reformatted
mv otus.98.taxonomy.reformatted otus.98.taxonomy
sed 's/[[:blank:]]/\;/' <otus.general.taxonomy >otus.general.taxonomy.reformatted
mv otus.general.taxonomy.reformatted otus.general.taxonomy
mkdir conflicts_98
Rscript find_classification_disagreements.R otus.98.taxonomy otus.general.taxonomy ids.above.98 conflicts_98 98 85 70
Rscript find_classification_disagreements.R otus.98.taxonomy otus.general.taxonomy ids.above.98 conflicts_98 98 85 70 final
#Copy and modify the taxonomy file to meet Ananke's requirements
cp final.taxonomy.names temp
sed -i 's/,/\t/' temp
sed -i 's/,/;/g' temp
#tail -n +2 temp > taxonomy.txt
#For the full sequence run:
tail -n +2 temp > taxonomy_full.txt
rm temp
gzip *.fasta
