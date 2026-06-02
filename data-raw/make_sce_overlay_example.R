# data-raw/make_sce_overlay_example.R
set.seed(42L)

n_cells <- 300
n_genes <- 50

# gene names (include SOX10, S100B)
genes <- c("SOX10","S100B", paste0("Gene", seq_len(n_genes-2)))

# samples and types
sample <- factor(rep(paste0("S", 1:6), length.out = n_cells))
sample_type <- factor(rep(c("PNF","ANNUBP","MPNST"), length.out = n_cells))
cluster <- factor(sample.int(5, n_cells, replace = TRUE), labels = paste0("C", 1:5))
celltype.main <- factor(sample(c("Schwann","Mesenchymal","Immune","Endothelial"),
															 n_cells, replace = TRUE))
tumor_stage <- factor(sample(c("low","high"), n_cells, replace = TRUE))

# counts (simulate mild structure by sample_type)
lambda <- c(PNF=4, ANNUBP=6, MPNST=8)
counts <- matrix(rpois(n_genes * n_cells, lambda = lambda[as.character(sample_type)]),
								 nrow = n_genes, ncol = n_cells,
								 dimnames = list(genes, paste0("Cell", seq_len(n_cells))))

# boost SOX10/S100B in Schwann-like and PNF-ish cells
schwann_idx <- which(celltype.main == "Schwann")
counts["SOX10", schwann_idx] <- counts["SOX10", schwann_idx] + rpois(length(schwann_idx), 6)
counts["S100B", schwann_idx] <- counts["S100B", schwann_idx] + rpois(length(schwann_idx), 5)

# SCE
library(SingleCellExperiment)
sce_overlay_example <- SingleCellExperiment(
	assays = list(counts = counts,
								logcounts = log1p(counts))
)

# colData
SummarizedExperiment::colData(sce_overlay_example) <- DataFrame(
	sample = sample,
	sample_type = sample_type,
	cluster = cluster,
	celltype.main = celltype.main,
	tumor_stage = tumor_stage
)

# toy reducedDims (use PCA for structure)
pc <- prcomp(t(log1p(counts)), center = TRUE, scale. = TRUE)$x[, 1:2]
reducedDim(sce_overlay_example, "TSNE") <- pc + matrix(rnorm(length(pc), sd = 0.2), ncol = 2)
reducedDim(sce_overlay_example, "UMAP") <- pc + matrix(rnorm(length(pc), sd = 0.2), ncol = 2)

# save data to data/ as .rda
dir.create("data", showWarnings = FALSE)
save(sce_overlay_example, file = "data/sce_overlay_example.rda", compress = "bzip2")
message("Saved data/sce_overlay_example.rda")
