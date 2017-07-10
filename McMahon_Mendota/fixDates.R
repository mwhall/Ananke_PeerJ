#!/usr/bin/env Rscript

library(lubridate)

md <- read.table("sequence_data/METADATA.txt",sep="\t",header=TRUE,comment.char="")

minDate <- min(as.Date(md$collection_timestamp, format="%m/%d/%Y"))
md$time_points <- as.numeric(as.Date(md$collection_timestamp, format="%m/%d/%Y") - minDate)

colnames(md)[1] <- "#SampleID"

#Now we read in the DADA2 results so that we can filter out bad time points
d2 <- read.table("sequence_data/dada2_omega1e2.csv")
keep <- colnames(d2[colSums(d2)>=1000])
#Filter out low count samples
md <- md[md[,"#SampleID"] %in% keep,]

write.table(md, "sequence_data/METADATA_modified.txt", sep="\t", quote=FALSE, row.names=FALSE)
