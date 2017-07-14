
#Packages to import
library(ggplot2)
library(reshape2)
library(cowplot)
library(lubridate)

#Import data
tsc <- read.table("timeseries_cluster-eps_0.1-num_26.csv",sep=",",header=TRUE)
tp.int <- read.table("timeseries_cluster-eps_0.1-num_26.csv",sep=",",header=FALSE)[1,6:ncol(tsc)]
#This is the first sample date
basedate <- date("2000-03-15")
#Make the rest of the dates offset from the base date
tp <- basedate + as.numeric(tp.int)
#Load this in for normalization
all <- read.table("all_clusters-eps_0.1.csv",sep=",",header=TRUE)
all.sum <- colSums(all[,7:ncol(all)])
#Normalize by sample sequence depth
tsc[,6:ncol(tsc)] <- t(t(tsc[,6:ncol(tsc)])/all.sum)

#Read in the OTU
otu <- read.table("otu_num_464.csv", sep=",", header=TRUE)
#Normalize by sample sequence depth
otu[,6:ncol(otu)] <- t(t(otu[,6:ncol(otu)])/all.sum)
#Melt for ggplot
otu.m <- melt(t(otu[,6:ncol(otu)]))
otu.df <- data.frame(Sequence=otu.m$Var2, Abundance=otu.m$value, Time=tp, TSC=rep(otu$TimeClustNumber, each=length(tp)))
otu.df <- otu.df[otu.df$TSC %in% c("6","84"),]
otu.df$TSC <- paste("TSC", otu.df$TSC)
otu.df$TSC <- factor(otu.df$TSC, levels=c("TSC 6","TSC 84"))

#Melt for ggplot
tsc.m <- melt(t(tsc[,6:ncol(tsc)]))
nseqs <- dim(tsc.m)[1]/length(tp)
classifications <- rep(tsc$TaxonomicID, each=length(tp))
df <- data.frame(Sequence=tsc.m$Var2, Abundance=tsc.m$value, Taxonomy=classifications, Time=tp)
#Filter out all the other stuff so we have a tidier plot featuring the abundant organisms only
keeptax <- c("k__Bacteria;p__Cyanobacteria;c__Synechococcophycideae;o__Synechococcales;f__Synechococcaceae;g__Synechococcus;unclassified",
             "k__Bacteria;p__Bacteroidetes;c__[Saprospirae];o__[Saprospirales];bacI;bacI-A;unclassified")
df <- df[df$Taxonomy %in% keeptax,]
levels(df$Taxonomy)[levels(df$Taxonomy)==keeptax[1]] <- "Synechococcus"
levels(df$Taxonomy)[levels(df$Taxonomy)==keeptax[2]] <- "bacI-A"

#Left panel
p1<-ggplot(df, aes(x=Time, y=Abundance, color=Taxonomy, group=Sequence))+geom_line(alpha=0.7)+facet_grid(Taxonomy~., scale="free_y")+
ylab("Relative Abundance")+theme(legend.position="none")+scale_x_date(date_labels="%Y", date_breaks="1 year")+
geom_vline(xintercept=as.numeric(date("2000-09-01")+years(0:10)),alpha=0.5, col="yellow")+
ggtitle("TSC 26")

ggsave("MendotaFig1.pdf", height=4, width=7)

#Right panel
p2<-ggplot(otu.df, aes(x=Time, y=Abundance, group=Sequence, colour=as.factor(TSC)))+geom_line(alpha=0.7)+facet_grid(TSC~., scale="free_y")+
ylab("Relative Abundance")+theme(legend.position="none")+scale_x_date(date_labels="%Y", date_breaks="1 year")+
geom_vline(xintercept=as.numeric(date("2000-09-01")+years(0:10)),alpha=0.5, col="yellow")+
geom_vline(xintercept=as.numeric(date("2000-06-01")+years(0:10)),alpha=0.5, col="lightblue")+
scale_color_brewer(palette="Dark2")+ggtitle("OTU 464")

ggsave("MendotaFig1.5.pdf", height=4, width=7)

# Source : http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/
# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)

  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)

  numPlots = length(plots)

  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }

 if (numPlots==1) {
    print(plots[[1]])

  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

#Plot both figures side-by-side as well
pdf("Figure5_revisions.pdf", width=14, height=4)
multiplot(p1,p2,cols=2)
dev.off()


