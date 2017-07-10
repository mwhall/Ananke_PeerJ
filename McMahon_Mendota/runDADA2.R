library(dada2)
path <- "./sequence_data"
fqs <- sort(list.files(path, pattern=".fastq.gz"))
sample.names <- sapply(strsplit(fqs, "\\."), `[`, 1)
fqs <- file.path(path, fqs)
#plotQualityProfile(fqs[1:2])
filt_path <- file.path(path, "filtered") # Place filtered files in filtered/ subdirectory
filtfqs <- file.path(filt_path, paste0(sample.names, "_filt.fastq.gz"))
#Leaving out trunclen since these data saw some truncation before EBI submission
out <- filterAndTrim(fqs, filtfqs,
              maxN=0, maxEE=2, truncQ=2, rm.phix=TRUE,
              compress=TRUE, multithread=TRUE)
err <- learnErrors(filtfqs, multithread=TRUE)
derepFs <- derepFastq(filtfqs, verbose=TRUE)
names(derepFs) <- sample.names
#Use OMEGA_A=1e-2 as a "light touch" filter
dadaFs <- dada(derepFs, err=err, multithread=TRUE, OMEGA_A=1e-2)
seqtab <- makeSequenceTable(dadaFs)
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)

getN <- function(x) sum(getUniques(x))
track <- cbind(out, sapply(dadaFs, getN), rowSums(seqtab), rowSums(seqtab.nochim))
colnames(track) <- c("input", "filtered", "denoised", "tabled", "nonchim")
rownames(track) <- sample.names
head(track)
write.table(t(seqtab.nochim), "sequence_data/dada2_omega1e2.csv")
