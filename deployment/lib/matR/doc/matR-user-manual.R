### R code from vignette source 'matR-user-manual.Rnw'

###################################################
### code chunk number 1: matR-user-manual.Rnw:16-19
###################################################
options(width=80)
options(prompt="> ")
library(matR)


###################################################
### code chunk number 2: sec-preliminaries.Rnw:12-13 (eval = FALSE)
###################################################
## install.packages("matR", repo="http://dunkirk.mcs.anl.gov/~braithwaite/R", type="source")


###################################################
### code chunk number 3: sec-preliminaries.Rnw:16-17 (eval = FALSE)
###################################################
## library(matR)


###################################################
### code chunk number 4: sec-preliminaries.Rnw:20-21 (eval = FALSE)
###################################################
## dependencies()


###################################################
### code chunk number 5: sec-preliminaries.Rnw:24-28 (eval = FALSE)
###################################################
## install.packages("RJSONIO")
## install.packages("ecodist")
## install.packages("gplots")
## install.packages("scatterplot3d")


###################################################
### code chunk number 6: sec-preliminaries.Rnw:38-41
###################################################
sample(1:200)
m <- matrix(sample (1:200), nrow=20, ncol=10)
m


###################################################
### code chunk number 7: sec-preliminaries.Rnw:44-46
###################################################
apply(m,1,mean)
apply(m,2,mean)


###################################################
### code chunk number 8: sec-preliminaries.Rnw:49-52
###################################################
df <- data.frame(mu=apply(m,2,mean), sigma=apply(m,2,sd))
df$sample <- paste("sample", LETTERS[1:10], sep = "-")
df


###################################################
### code chunk number 9: sec-preliminaries.Rnw:55-57
###################################################
df [c(1,3)] <- df [c(3,1)]
df


###################################################
### code chunk number 10: sec-preliminaries.Rnw:61-63
###################################################
rownames(df)
colnames(df)


###################################################
### code chunk number 11: sec-preliminaries.Rnw:66-68
###################################################
colnames(df) [c(1,3)] <- colnames(df) [c(3,1)]
df


###################################################
### code chunk number 12: sec-preliminaries.Rnw:71-75
###################################################
head(m)
tail(m)
str(m)
str(df)


###################################################
### code chunk number 13: sec-preliminaries.Rnw:78-79
###################################################
boxplot(m)


###################################################
### code chunk number 14: sec-preliminaries.Rnw:90-91 (eval = FALSE)
###################################################
## vignette("matR-quick-reference")


###################################################
### code chunk number 15: sec-preliminaries.Rnw:96-97 (eval = FALSE)
###################################################
## ?command


###################################################
### code chunk number 16: sec-preliminaries.Rnw:100-103 (eval = FALSE)
###################################################
## ?mean
## ?sample
## ?apply


###################################################
### code chunk number 17: sec-preliminaries.Rnw:106-108 (eval = FALSE)
###################################################
## ??random
## ??plot


###################################################
### code chunk number 18: sec-preliminaries.Rnw:111-112 (eval = FALSE)
###################################################
## library(help="matR")


###################################################
### code chunk number 19: sec-preliminaries.Rnw:115-116 (eval = FALSE)
###################################################
## vignette("matR-change-log")


###################################################
### code chunk number 20: sec-preliminaries.Rnw:126-127 (eval = FALSE)
###################################################
## asFile(cc$raw, file="saved_matrix.txt")


###################################################
### code chunk number 21: sec-preliminaries.Rnw:130-134 (eval = FALSE)
###################################################
## cc <- collection("4441679.3 4441680.3 4441682.3")
## write.table(cc$raw, file="data.txt", sep="\t")
## x <- read.table(file="data.txt")
## x


###################################################
### code chunk number 22: sec-preliminaries.Rnw:137-145 (eval = FALSE)
###################################################
## cc <- collection("4441679.3 4441680.3 4441682.3")
## p <- pco(cc)
## ls()
## save(cc, p, file="saved_data.Rda")
## rm(cc, p)
## ls()
## load(file="saved_data.Rda")
## ls()


###################################################
### code chunk number 23: sec-preliminaries.Rnw:148-149 (eval = FALSE)
###################################################
## pco(Waters, main="functional level 3", col=c(rep("red",12),rep("blue",12)))


###################################################
### code chunk number 24: sec-preliminaries.Rnw:152-155 (eval = FALSE)
###################################################
## pdf(filename="my_pco.pdf", width=5, height=5)
## pco(Waters, main="functional level 3", col=c(rep("red",12),rep("blue",12)))
## dev.off()


###################################################
### code chunk number 25: matR-user-manual.Rnw:31-32
###################################################
readLines("_data/sex")


###################################################
### code chunk number 26: sec-basics.Rnw:8-11 (eval = FALSE)
###################################################
## c(level="level1")
## c(annot="organism",level="phylum")
## c(entry="normed.counts",source="NOG")


###################################################
### code chunk number 27: sec-basics.Rnw:16-19 (eval = FALSE)
###################################################
## view.descriptions
## view.parameters
## view.defaults


###################################################
### code chunk number 28: sec-basics.Rnw:27-31 (eval = FALSE)
###################################################
## IDs <- c(gut1="4441695.3", gut2="4441696.3")
## cc <- collection(IDs)
## dd <- collection("4441679.3 4441680.3 4441682.3 4441695.3 4441696.3 4440463.3 4440464.3")
## ee <- collection(file="test-IDs.txt")


###################################################
### code chunk number 29: sec-basics.Rnw:36-50 (eval = FALSE)
###################################################
## collection(IDs,
##   raw=c(entry="count"), 
##   nrm=c(entry="normed.counts"))
## collection(IDs, 
##   L1=c(level="level1"), L2=c(level="level2"), 
##   L3=c(level="level3"), L4=c(level="function"))
## collection(IDs,
##   nog=c(source="NOG"), 
##   cog=c(source="COG"), 
##   ko=c(source="KO"))
## collection(IDs, 
##   lca=c(annot="organism", hit="lca"), 
##   repr=c(annot="organism", hit="single"), 
##   all=c(annot="organism", hit="all"))


###################################################
### code chunk number 30: sec-basics.Rnw:53-65 (eval = FALSE)
###################################################
## top.levels <- list(
##   L1=c(level="level1"), 
##   L2=c(level="level2"))
## all.ontologies <- list(
##   nog=c(source="NOG"), 
##   cog=c(source="COG"), 
##   ko=c(source="KO"),
##   sub=c(source="Subsystems"))
## all.count.methods <- list(
##   lca=c(annot="organism", hit="lca"), 
##   repr=c(annot="organism", hit="single"), 
##   all=c(annot="organism", hit="all"))


###################################################
### code chunk number 31: sec-basics.Rnw:68-71 (eval = FALSE)
###################################################
## cc <- collection (guts, top.levels)
## dd <- collection (guts, all.ontologies)
## ee <- collection (guts, all.count.methods)


###################################################
### code chunk number 32: sec-basics.Rnw:74-77 (eval = FALSE)
###################################################
## cc$L1
## dd$nog
## ee$all


###################################################
### code chunk number 33: sec-basics.Rnw:80-81 (eval = FALSE)
###################################################
## dd$cog <- c(source="COG")


###################################################
### code chunk number 34: sec-basics.Rnw:84-91 (eval = FALSE)
###################################################
## samples(cc)      # show metagenomes in the collection
## projects(cc)     # show projects in the collection
## names(cc)        # show names of metagenomes
## views(cc)        # show the data views in the collection
## viewnames(cc)    # show just the names of the views
## groups(cc)       # show grouping of metagenomes (if assigned)
## metadata(cc)     # access metadata


###################################################
### code chunk number 35: sec-basics.Rnw:94-95 (eval = FALSE)
###################################################
## names(cc) <- c("new.name.1", "new.name.2")


###################################################
### code chunk number 36: sec-basics.Rnw:98-102 (eval = FALSE)
###################################################
## rownames(Guts, view="raw", sep=NULL)
## rownames(Guts, view="raw", sep=FALSE)
## rownames(Guts, view="raw", sep=TRUE)
## rownames(Guts, view="raw", sep="\t")


###################################################
### code chunk number 37: sec-basics.Rnw:107-108 (eval = FALSE)
###################################################
## ff <- dd[1:3]


###################################################
### code chunk number 38: sec-basics.Rnw:115-116 (eval = FALSE)
###################################################
## metadata(Guts)


###################################################
### code chunk number 39: sec-basics.Rnw:119-120 (eval = FALSE)
###################################################
## metadata(Guts)["4440464.3"]


###################################################
### code chunk number 40: sec-basics.Rnw:123-124 (eval = FALSE)
###################################################
## metadata(Guts)["latitude", "longitude"]


###################################################
### code chunk number 41: sec-basics.Rnw:127-128 (eval = FALSE)
###################################################
## metadata(Guts)["latitude", "longitude", bygroup=TRUE]


###################################################
### code chunk number 42: sec-basics.Rnw:131-132 (eval = FALSE)
###################################################
## metadata(Guts)["host_common_name", "disease", ".age", bygroup=TRUE]


###################################################
### code chunk number 43: sec-basics.Rnw:135-136 (eval = FALSE)
###################################################
## metadata(Guts)[c("4440464.3","env_package.data")]


###################################################
### code chunk number 44: sec-basics.Rnw:139-140 (eval = FALSE)
###################################################
## metadata(Guts)[c("env","temp"), c("4440464.3","PI_organization"), c("0464","biome")]


###################################################
### code chunk number 45: sec-basics.Rnw:143-144 (eval = FALSE)
###################################################
## mm <- metadata("4441679.3 4441680.3 4441682.3 4441695.3 4441696.3")


###################################################
### code chunk number 46: sec-analysis.Rnw:20-23 (eval = FALSE)
###################################################
## cc <- collection(...)
## ns <- remove.singletons(cc$raw)
## nrm <- normalize(r)


###################################################
### code chunk number 47: sec-analysis.Rnw:29-31 (eval = FALSE)
###################################################
## dist(m, method="bray-curtis", bycol=TRUE)
## dist(m, groups=c(1,1,1,2,2,2,3,3,4,4,4,4), bycol=TRUE)


###################################################
### code chunk number 48: sec-analysis.Rnw:34-36 (eval = FALSE)
###################################################
## dist(m, y, bycol=TRUE)
## dist(m, y, groups=c(1,1,1,2,2,2,3,3,4,4,4,4), bycol=TRUE)


###################################################
### code chunk number 49: sec-analysis.Rnw:42-45 (eval = FALSE)
###################################################
## sigtest (m, groups=c(1,1,1,2,2,2,3,3,4,4,4,4), test="Kruskal-Wallis")
## sigtest (m, groups=c(1,1,1,2,2,2,3,3,4,4,4,4), test="Kruskal-Wallis", qvalue=TRUE)
## sigtest (m, groups=c(1,1,1,2,2,2,3,3,4,4,4,4), test="Kruskal-Wallis", qvalue=TRUE, fdr.level=0.01)


###################################################
### code chunk number 50: sec-analysis.Rnw:50-55 (eval = FALSE)
###################################################
## randomize (m)
## randomize (m, n=10, method="sample")
## randomize (m, n=10, method="rowwise", FUN=mean)
## randomize (m, n=10, method="dataset", FUN=colSums, na.rm=TRUE)
## randomize (m, n=10, method="complete", FUN=function (m) apply (m, MARGIN=2, hist, plot=FALSE))


###################################################
### code chunk number 51: sec-analysis.Rnw:62-65 (eval = FALSE)
###################################################
## render(Waters)
## render (Waters, notch = TRUE, pch = 19, cex = 0.5, names = names (waters),
## main = "Annotation Diversity at Function Level 3", cex.axis = 1.1)


###################################################
### code chunk number 52: sec-analysis.Rnw:71-78 (eval = FALSE)
###################################################
## pco(cc)
## col <- factor (metadata (cc) ["biome"])
## levels (col) <- c ("#1F78B4", "#E31A1C", "#B15928")
## col.vec <- as.character (col)
## pco (cc, view="norm", comp = c (2,3,4), sub = "Principal Coordinates 2 to 4", cex.sub = 1.5,
## main = "", color = col.vec, labels = "", cex = 1.5, lty.hplot="dashed", 
## mar = c (5,5,0,3))


###################################################
### code chunk number 53: sec-analysis.Rnw:84-89 (eval = FALSE)
###################################################
## cc <- collection("....", n1 = c(entry="ns.normed.counts", level="level1"), raw=default.views$raw)
## test.result <- sigtest(cc$n1, "Kruskal")
## red.yellow <- rgb (colorRamp(c ("#FFFFCC", "#800026")) (seq(0, 1, length = 20)), max = 255)
## heatmap(cc)
## heatmap(cc, view="n1", rows=test.result$significant, main="significant annotations only", labRow=NA, labCol=names(cc), col=red.yellow)


###################################################
### code chunk number 54: matR-user-manual.Rnw:69-70 (eval = FALSE)
###################################################
## mGet("metagenome_statistics", "mgm4472882.3")


###################################################
### code chunk number 55: matR-user-manual.Rnw:73-74 (eval = FALSE)
###################################################
## callRaw("metagenome_statistics/mgm4472882.3")


