##############################################################

### Step 4: Allele specific expression analysis (gold standard)

##############################################################

liver.mouse.eQTL.bayesian <- read.table(file = "liver.mouse.eQTL.bayesian with beta.txt")
liver.mouse.eQTL.bayesian.tau <- liver.mouse.eQTL.bayesian
### ASE
liver.ASE <- read.csv(file = "ASE.genetics.113.153882-6.csv")
# 440 unique gene ID
length(unique(liver.ASE$geneID))
# verify ASE table
liver.ASE1 <- liver.ASE[which(liver.ASE$replicate == "M.CH. DxB and BxD"), ]
liver.ASE2 <- liver.ASE[which(liver.ASE$replicate == "M.HF DxB and BxD"), ]
liver.ASE3 <- liver.ASE[which(liver.ASE$replicate == "F.HF DxB and BxD"), ]
length(unique(liver.ASE1$geneID))
length(unique(liver.ASE2$geneID))
length(unique(liver.ASE3$geneID))
(length(unique(liver.ASE1$geneID)) + length(unique(liver.ASE2$geneID)) + 
    length(unique(liver.ASE3$geneID)))/3
# As claimed in the paper: averaged 284 ASE for each replicate
sub.liver.ASE <- liver.ASE1
summary(sub.liver.ASE$pvalBH.DxB7)
sub.liver.ASE1 <- subset(sub.liver.ASE, pvalBH.DxB7 < 1e-14)
sub.liver.ASE2 <- subset(sub.liver.ASE, pvalBH.DxB7 >= 1e-14 & pvalBH.DxB7 < 5.8e-06)
sub.liver.ASE3 <- subset(sub.liver.ASE, pvalBH.DxB7 >= 5.8e-06 & pvalBH.DxB7 < 0.0031)
sub.liver.ASE4 <- subset(sub.liver.ASE, pvalBH.DxB7 >= 0.0031 & pvalBH.DxB7 >= 0.0031)
dim(sub.liver.ASE1)
dim(sub.liver.ASE2)
dim(sub.liver.ASE3)
dim(sub.liver.ASE4)
# sub.liver.ASE <- sub.liver.ASE[ sub.liver.ASE$geneID %in%
# names(table(sub.liver.ASE$geneID))[table(sub.liver.ASE$geneID) >1]
# , ] check the remain gene number after subsetting
dim(sub.liver.ASE)
liver.ASE.symbol <- unique(sub.liver.ASE$geneID)
liver.ASE.symbol1 <- unique(sub.liver.ASE1$geneID)
liver.ASE.symbol2 <- unique(sub.liver.ASE2$geneID)
liver.ASE.symbol3 <- unique(sub.liver.ASE3$geneID)
liver.ASE.symbol4 <- unique(sub.liver.ASE4$geneID)
length(liver.ASE.symbol)
# Annoate gene symbol with ensemble.ID
library(biomaRt)
mouse <- useMart("ensembl", dataset = "mmusculus_gene_ensembl")
liver.ASE.ensembl <- getBM(attributes = c("ensembl_gene_id", "mgi_symbol"), filters = "mgi_symbol", 
                           values = liver.ASE.symbol, mart = mouse)
liver.ASE.ensembl1 <- getBM(attributes = c("ensembl_gene_id", "mgi_symbol"), filters = "mgi_symbol", 
                            values = liver.ASE.symbol1, mart = mouse)
liver.ASE.ensembl2 <- getBM(attributes = c("ensembl_gene_id", "mgi_symbol"), filters = "mgi_symbol", 
                            values = liver.ASE.symbol2, mart = mouse)
liver.ASE.ensembl3 <- getBM(attributes = c("ensembl_gene_id", "mgi_symbol"), filters = "mgi_symbol", 
                            values = liver.ASE.symbol3, mart = mouse)
liver.ASE.ensembl4 <- getBM(attributes = c("ensembl_gene_id", "mgi_symbol"), filters = "mgi_symbol", 
                            values = liver.ASE.symbol4, mart = mouse)
dim(liver.ASE.ensembl)
liver.ASE.ensembl <- unique(liver.ASE.ensembl)

# delete liver ASE ensemble ID which are not in the
# liver.mouse.eQTL.bayesian data frame
liver.ASE.ensembl <- liver.ASE.ensembl[liver.ASE.ensembl$ensembl_gene_id %in% liver.mouse.eQTL.bayesian.tau$ensembl_id, ]
write.table(liver.ASE.ensembl, "liver.ASE.ensembl.txt")
liver.mouse.eQTL.bayesian.tau$eqtl[liver.mouse.eQTL.bayesian.tau$ensembl_id %in% liver.ASE.ensembl$ensembl_gene_id] <- 1
liver.mouse.eQTL.bayesian.tau$eqtl[!liver.mouse.eQTL.bayesian.tau$ensembl_id %in% liver.ASE.ensembl$ensembl_gene_id] <- 0
write.table(liver.mouse.eQTL.bayesian.tau, "liver.mouse.eQTL.bayesian.tau.txt")
summary(liver.mouse.eQTL.bayesian.tau$eqtl)
liver.mouse.eQTL.bayesian.tau$neg_log_liver_pvalue <- -log10(liver.mouse.eQTL.bayesian.tau$liver_pvalue)
by(liver.mouse.eQTL.bayesian.tau[, c(1, 7, 9, 14)], liver.mouse.eQTL.bayesian.tau[, "eqtl"], summary)
library(ggplot2)
boxplot(neg_log_liver_pvalue ~ eqtl, data = liver.mouse.eQTL.bayesian.tau, main = "liver.mouse.eQTL", xlab = "group", 
        ylab = "liver neg log p")
boxplot(neg_log_lung_pvalue ~ eqtl, data = liver.mouse.eQTL.bayesian.tau, main = "lung.mouse.eQTL", xlab = "group", 
        ylab = "lung neg log p")
liver.mouse.eQTL.bayesian.tau$eqtl[liver.mouse.eQTL.bayesian.tau$ensembl_id %in% liver.ASE.ensembl$ensembl_gene_id] <- "ASE"
liver.mouse.eQTL.bayesian.tau$eqtl[!liver.mouse.eQTL.bayesian.tau$ensembl_id %in% liver.ASE.ensembl$ensembl_gene_id] <- "Non-ASE"
pdf("boxplot01.pdf")
boxplot(neg_log_liver_pvalue ~ eqtl, data = liver.mouse.eQTL.bayesian.tau, main = "liver.mouse.eQTL", xlab = "group", 
        ylab = "liver neg log p")
dev.off()
# boxplot(neg_log_lung_pvalue ~
# eqtl,data=liver.mouse.eQTL.bayesian.tau, main='lung.mouse.eQTL',
# xlab=group', ylab='lung neg log p', ylim=c(0, 16))
pdf("boxplot02.pdf")
boxplot(neg_log_lung_pvalue ~ eqtl, data = liver.mouse.eQTL.bayesian.tau, main = "lung.mouse.eQTL", xlab = "group", 
        ylab = "lung neg log p")
dev.off()
pdf("boxplot.pdf", width = 9, height = 6)
par(mfrow = c(1, 2))
par(mar=c(5,5,2,2))
boxplot(neg_log_lung_pvalue ~ eqtl, data = liver.mouse.eQTL.bayesian.tau, main = "lung mouse cis-eQTL", xlab = "group", 
        ylab = "lung neg log p", cex.lab= 1.8, cex.axis=1.5, ylim = c(0, 40), asp = 0.5)
boxplot(neg_log_liver_pvalue ~ eqtl, data = liver.mouse.eQTL.bayesian.tau, main = "liver mouse cis-eQTL", xlab = "group", 
        ylab = "liver neg log p",cex.lab= 1.8, cex.axis=1.5, ylim = c(0, 40), asp = 0.5) 
dev.off()
