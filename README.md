# Ananke_PeerJ
Scripts useful for reproducing the results in the Ananke manuscript found in PeerJ PrePrints (currently under revision for PeerJ)

Two data-sets were processed with Ananke in this publication, a freshwater lake data set and a stool dataset. To reproduce the analyses in the publication, pull the scripts with `git clone https://github.com/mwhall/Ananke_PeerJ.git`.

# Required Software

* ananke (v0.3)
* ananke-ui
* R (v3.4.0)
* DADA2 (v1.4)
* lubridate (v1.6.0)
* awk
* curl
* wget

# Freshwater Lake

Data is from the North Temperate Lakes Long-term Ecological Research Network (https://lter.limnology.wisc.edu/). Sequences are at EBI project accession PRJEB14911.

Scripts are found in the `McMahon_Mendota` directory. There are 4 scripts that must be run in the presented order:

* fetchData.sh
...BASH script that communicates with EBI to download the .fastq.gz files directly, as well as all associated sample metadata.
* runDADA2.R
...R script that runs `DADA2` v1.4 to denoise the sequences, remove PhiX, and filter out bimeras.
* fixDates.R
...R script that uses `lubridate` to convert the dates in the metadata to integer offsets from the earliest date (a requirement for Ananke v0.3). It also removes low sequence-depth samples from the metadata file, which excludes them from the Ananke analysis.
* Ananke.sh
...BASH script that runs the Ananke commands to import DADA2 results, cluster, and then import the taxonomic classifications and the sequence-identity clusters.

# Stool

Data is from David _et al._, 2014 (https://genomebiology.biomedcentral.com/articles/10.1186/gb-2014-15-7-r89). Sequences are at EBI project accession PRJEB6518.

Scripts are found in the `Alm_Stool` directory. There are 3 scripts that must be run in the presented order:

* fetchData.sh
...BASH script that communicates with EBI to download the .fastq.gz files directly, as well as all associated sample metadata.
* runDADA2.R
...R script that runs `DADA2` v1.4 to denoise the sequences, remove PhiX, and filter out bimeras.
* Ananke.sh
...BASH script that runs the Ananke commands to import DADA2 results, cluster, and then import the taxonomic classifications and the sequence-identity clusters.
