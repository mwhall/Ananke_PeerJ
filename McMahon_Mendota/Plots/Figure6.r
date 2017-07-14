
#Libraries to import
library(ggplot2)
library(reshape2)
library(cowplot)
library(lubridate)

#Read in all data
all <- read.table("all_clusters-eps_0.1.csv",sep=",",header=TRUE)
all.sum <- colSums(all[,7:ncol(all)])
#Normalize by column
all[,7:ncol(all)] <- t(t(all[,7:ncol(all)])/all.sum)
#Read in time points, then set as offset from first sample date
tp.int <- read.table("all_clusters-eps_0.1.csv",sep=",",header=FALSE)[1,7:ncol(all)]
basedate <- date("2000-03-15")
tp <- basedate + as.numeric(tp.int)
#acI-A: main 223, 241, 350,... 200, 348
#acI-B: main 101, 257
#acI-C: main 1, 129, 605
# Compute the proportional abundances
print("acI-A proportion:")
all.acIa <- all[grep(";acI-A;", all$TaxonomicID),]
sum(all.acIa[,7:ncol(all.acIa)])/sum(all[,7:ncol(all)])
max(all.acIa$Abundance)/sum(all.acIa$Abundance)
print("acI-B proportion:")
all.acIb <- all[grep(";acI-B;", all$TaxonomicID),]
sum(all.acIb[,7:ncol(all.acIb)])/sum(all[,7:ncol(all)])
max(all.acIb$Abundance)/sum(all.acIb$Abundance)
print("acI-C proportion:")
all.acIc <- all[grep(";acI-C;", all$TaxonomicID),]
sum(all.acIc[,7:ncol(all.acIc)])/sum(all[,7:ncol(all)])
max(all.acIc$Abundance)/sum(all.acIc$Abundance)

#Filter only the TSC that we want to show
all <- all[all$TimeCluster %in% c(223, 241, 350, 200, 101, 257, 1, 129, 605), ]
#Normalize by row (comment out if you want to see sequences on a more interpretable scale)
for (row in rownames(all)) { all[row, 7:ncol(all)] <- all[row, 7:ncol(all)] / sum(all[row, 7:ncol(all)]) }
#Melt for ggplot2
all.m <- melt(t(all[, 7:ncol(all)]))
df <- data.frame(Time=tp, Abundance=all.m$value, Sequence=all.m$Var2, TSC=as.factor(rep(all$TimeCluster, each=length(tp))))
df$Clade[df$TSC %in% c(223, 241, 350, 200)] <- "acI-A"
df$Clade[df$TSC %in% c(101, 257)] <- "acI-B"
df$Clade[df$TSC %in% c(1, 129, 605)] <- "acI-C"
df$TSC <- paste("TSC", df$TSC)
df$TSC <- factor(df$TSC, levels=c("TSC 223","TSC 241","TSC 350", "TSC 200", "TSC 101","TSC 257","TSC 1","TSC 129","TSC 605"))

#Consistent number of decimal points, for consistency
fmt_dcimals <- function(){
   # return a function responpsible for formatting the 
   # axis labels with a given number of decimals 
   function(x) sprintf("%.3f", x)
}
ggplot(df, aes(x=Time, y=Abundance, group=Sequence, colour=Clade))+
geom_line(alpha=0.7)+facet_grid(TSC~., scale="free_y")+scale_x_date(date_labels="%Y", date_breaks="1 year")+
ylab("Relative Abundance")+theme(legend.position="top")+
geom_vline(xintercept=as.numeric(date("2000-11-01")+years(0:10)),alpha=0.5, col="yellow")+
geom_vline(xintercept=as.numeric(date("2000-05-01")+years(0:11)),alpha=0.5, col="lightblue")+
scale_y_continuous(labels = fmt_dcimals())

ggsave("MendotaFig2_normal.pdf",height=8,width=7)


