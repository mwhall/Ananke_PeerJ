
#Libraries to import
library(ggplot2)
library(reshape2)
library(cowplot)

#Import OTUs
otu6 <- read.table("otu_num_6.csv",sep=",",header=TRUE)
otu505 <- read.table("otu_num_505.csv",sep=",",header=TRUE)
tp <- read.table("otu_num_6.csv",sep=",")[1,6:ncol(otu6)]
#Import all data for proper normalization
all <- read.table("all_clusters-eps_0.16.csv",sep=",")
tp.totals <- colSums(all[,7:ncol(all)])
ntp <- length(6:ncol(otu6))
tscs <- c()
for (tsc in otu6$TimeClustNumber) {
    tscs <- c(tscs, rep(tsc,ntp))
}
#Encode the second OTU's -1 cluster as a different label to avoid them getting the same colour
for (tsc in otu505$TimeClustNumber) {
    if (tsc == -1) {tsc<--2}
    tscs <- c(tscs, rep(tsc,ntp))
}

#Melt the data
otu6 <- melt(t(otu6[,6:ncol(otu6)]))
otu6$value <- otu6$value/tp.totals
otu505 <- melt(t(otu505[,6:ncol(otu505)]))
otu505$value <- otu505$value/tp.totals
#Numbering starts at 1 for each cluster, so add the previous max
otu505$Var2 <- otu505$Var2 + max(otu6$Var2)

#Turn it into a data frame
clusters <- rbind(otu6,otu505)
df <- data.frame(TSC=as.factor(tscs),Sequence=clusters$Var2, Abundance=clusters$value, OTU=as.factor(c(rep(6,dim(otu6)[1]),rep(505,dim(otu505)[1]))), Time=rep(as.vector(t(tp)),dim(clusters)[1]/length(tp)))
levels(df$OTU) <- c("OTU 6", "OTU 505")

#Plot
p<-ggplot(df, aes(x=Time, y=Abundance, color=TSC, group=Sequence))+geom_line(alpha=0.7)
p<-p+xlab("Time (days)")+ylab("Sequence Relative Abundance")+theme(legend.position='none')+facet_grid(OTU~.,scales="free_y")

p

ggsave("Figure4.pdf",p,width=4,height=4)


