
#Libraries to import
library(ggplot2)
library(reshape2)
library(cowplot)

#Read in files, then grab the time points from a header
c3 <- read.table("timeseries_cluster-eps_0.16-num_3.csv",sep=",",header=TRUE)
c6 <- read.table("timeseries_cluster-eps_0.16-num_6.csv",sep=",",header=TRUE)
c8 <- read.table("timeseries_cluster-eps_0.16-num_8.csv",sep=",",header=TRUE)
tp <- read.table("timeseries_cluster-eps_0.16-num_3.csv",sep=",")[1,6:ncol(c3)]
all <- read.table("all_clusters-eps_0.16.csv",sep=",")
tp.totals <- colSums(all[,7:ncol(all)])

#Melt the data
c3 <- melt(t(c3[,6:ncol(c3)]))
c3$value <- c3$value/tp.totals
c6 <- melt(t(c6[,6:ncol(c6)]))
c6$value <- c6$value/tp.totals
#Numbering starts at 1 for each cluster, so add the previous max
c6$Var2 <- c6$Var2 + max(c3$Var2)
c8 <- melt(t(c8[,6:ncol(c8)]))
c8$Var2 <- c8$Var2 + max(c6$Var2)
c8$value <- c8$value/tp.totals
clusters <- rbind(c3, c6, c8)

#Make a data frame
df <- data.frame(Sequence=clusters$Var2, Abundance=clusters$value, TSC=as.factor(c(rep(3,dim(c3)[1]),rep(6,dim(c6)[1]),rep(8,dim(c8)[1]))), Time=rep(as.vector(t(tp)),dim(clusters)[1]/length(tp)))
levels(df$TSC)<-c("TSC 3", "TSC 6", "TSC 8")

#<3 ggplot
p<-ggplot(df, aes(x=Time,y=Abundance,color=as.factor(TSC),Group=Sequence))+geom_line(alpha=0.7)
p<-p+xlab("Time (days)")+ylab("Sequence Relative Abundance")+theme(legend.position='none')+facet_grid(TSC~.,scales="free_y")

ggsave("Figure3.pdf",p,width=4,height=5)


