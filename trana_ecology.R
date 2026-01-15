#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(vegan)
  library(phyloseq)
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(tools)
  library(UpSetR)
  # install.packages("UpSetR", repos="https://cloud.r-project.org")
})

# -----------------------------
# Args
# -----------------------------
args <- commandArgs(trailingOnly = TRUE)
input_dir  <- "."
output_dir <- "trana_ecology_out"
rank_for_plots <- "Genus"   # One of: Species, Genus, Family, Order, Class, Phylum, Kingdom, Domain
top_n <- 20                 # top taxa for stacked bar plot
presence_threshold <- 1e-6  # for presence/absence (avoid tiny floating noise)

i <- 1
while (i <= length(args)) {
  if (args[i] == "--input_dir" && i+1 <= length(args)) { input_dir <- args[i+1]; i <- i+2
  } else if (args[i] == "--output_dir" && i+1 <= length(args)) { output_dir <- args[i+1]; i <- i+2
  } else if (args[i] == "--rank" && i+1 <= length(args)) { rank_for_plots <- args[i+1]; i <- i+2
  } else if (args[i] == "--top_n" && i+1 <= length(args)) { top_n <- as.integer(args[i+1]); i <- i+2
  } else if (args[i] == "--presence_threshold" && i+1 <= length(args)) { presence_threshold <- as.numeric(args[i+1]); i <- i+2
  } else { i <- i+1 }
}

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# -----------------------------
# Read files (TRANA rel-abundance only)
# -----------------------------
sample_files <- list.files(input_dir, pattern="_rel-abundance\\.tsv$", full.names=TRUE)
if (length(sample_files) == 0) stop("No *_rel-abundance.tsv files found in ", input_dir)

read_one <- function(fp) {
  df <- read.table(fp, sep="\t", header=TRUE, stringsAsFactors=FALSE, quote="", comment.char="")
  names(df) <- trimws(names(df))

  req <- c("tax_id", "abundance")
  miss <- setdiff(req, names(df))
  if (length(miss) > 0) stop("Missing columns in ", basename(fp), ": ", paste(miss, collapse=", "))

  df <- df[!df$tax_id %in% c("unmapped", "mapped_unclassified"), , drop=FALSE]
  df$abundance <- as.numeric(df$abundance)
  df <- df[is.finite(df$abundance) & df$abundance >= 0, , drop=FALSE]
  df
}

all_data <- lapply(sample_files, read_one)

# Use nicer sample IDs:
# Option A: keep "SAMPLE_9_filtered.fastq"
names(all_data) <- sub("_rel-abundance\\.tsv$", "", basename(sample_files))

# -----------------------------
# Build taxa x samples matrix (relative abundance)
# Use tax_id as OTU/ASV key
# -----------------------------
all_taxa <- sort(unique(unlist(lapply(all_data, function(x) x$tax_id))))

otu <- matrix(0, nrow=length(all_taxa), ncol=length(all_data),
              dimnames=list(all_taxa, names(all_data)))

for (s in names(all_data)) {
  df <- all_data[[s]]
  otu[as.character(df$tax_id), s] <- df$abundance
}

# Optional sanity: per-sample sum should be ~1 (TRANA rel-abund)
sample_sums <- colSums(otu)
write.table(data.frame(Sample=names(sample_sums), SumRelAbund=sample_sums),
            file.path(output_dir, "sanity_sample_sums.tsv"),
            sep="\t", row.names=FALSE, quote=FALSE)

# -----------------------------
# Taxonomy table (best-effort)
# We will fill ranks if present in files
# -----------------------------
all_cols <- unique(unlist(lapply(all_data, names)))
rank_cols <- intersect(c("Species","Genus","Family","Order","Class","Phylum","Kingdom","Domain","organism_name"), all_cols)

tax_df <- data.frame(tax_id = all_taxa, stringsAsFactors = FALSE)

# fill from first occurrence across samples
for (rc in rank_cols) tax_df[[rc]] <- NA_character_

for (s in names(all_data)) {
  df <- all_data[[s]]
  keep <- df[, c("tax_id", rank_cols), drop=FALSE]
  # merge fill
  tax_df <- tax_df %>%
    left_join(keep, by="tax_id", suffix=c("", ".new")) %>%
    mutate(across(all_of(rank_cols), ~ ifelse(is.na(.), get(paste0(cur_column(), ".new")), .))) %>%
    select(-ends_with(".new"))
}

rownames(tax_df) <- tax_df$tax_id

# phyloseq taxonomy matrix must be character matrix
tax_mat <- as.matrix(tax_df[, setdiff(names(tax_df), "tax_id"), drop=FALSE])
tax_mat[is.na(tax_mat)] <- ""

# -----------------------------
# Sample metadata (simple; add your own if you have it)
# -----------------------------
smeta <- data.frame(
  Sample = colnames(otu),
  Group  = "Group1",
  stringsAsFactors = FALSE
)
rownames(smeta) <- smeta$Sample

ps <- phyloseq(
  otu_table(otu, taxa_are_rows = TRUE),
  sample_data(smeta),
  tax_table(tax_mat)
)

saveRDS(ps, file.path(output_dir, "phyloseq_trana_rel_abund.rds"))

# =========================================================
# Alpha diversity (works on relative abundances)
# =========================================================

otu_mat <- as(otu_table(ps), "matrix")  # taxa x samples
if (!taxa_are_rows(ps)) otu_mat <- t(otu_mat)

alpha <- data.frame(
  Sample   = colnames(otu_mat),
  Observed = colSums(otu_mat > 0),
  Shannon  = apply(otu_mat, 2, function(x) vegan::diversity(x, index="shannon")),
  Simpson  = apply(otu_mat, 2, function(x) vegan::diversity(x, index="simpson")),
  stringsAsFactors = FALSE
)

# Pielou evenness = Shannon / ln(richness)
alpha$Pielou <- with(alpha, ifelse(Observed > 1, Shannon / log(Observed), NA))

write.table(alpha, file.path(output_dir, "alpha_diversity.tsv"),
            sep="\t", row.names=FALSE, quote=FALSE)

p_alpha <- alpha %>%
  pivot_longer(cols=c("Observed","Shannon","Simpson","Pielou"),
               names_to="Metric", values_to="Value") %>%
  ggplot(aes(x=Sample, y=Value)) +
  geom_col() +
  facet_wrap(~Metric, scales="free_y", ncol=2) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle=45, hjust=1))

ggsave(file.path(output_dir, "alpha_diversity_bars.pdf"), p_alpha, width=10, height=7)

# =========================================================
# Beta diversity + ordinations
# =========================================================

# Bray-Curtis (abundance)
bray <- phyloseq::distance(ps, method="bray")
bray_mat <- as.matrix(bray)
write.table(bray_mat, file.path(output_dir, "beta_bray_curtis.tsv"),
            sep="\t", quote=FALSE)

# Jaccard presence/absence
otu_pa <- otu
otu_pa[otu_pa > presence_threshold] <- 1
otu_pa[otu_pa <= presence_threshold] <- 0
ps_pa <- phyloseq(otu_table(otu_pa, taxa_are_rows=TRUE), sample_data(smeta), tax_table(tax_mat))

jacc <- phyloseq::distance(ps_pa, method="jaccard", binary=TRUE)
jacc_mat <- as.matrix(jacc)
write.table(jacc_mat, file.path(output_dir, "beta_jaccard_pa.tsv"),
            sep="\t", quote=FALSE)

# PCoA (Bray)
ord_pcoa <- ordinate(ps, method="PCoA", distance=bray)
p_pcoa <- plot_ordination(ps, ord_pcoa, color="Group") +
  geom_point(size=3) +
  theme_minimal() +
  ggtitle("PCoA (Bray-Curtis)")
ggsave(file.path(output_dir, "ordination_pcoa_bray.pdf"), p_pcoa, width=8, height=6)

# NMDS (Bray)
set.seed(1)
ord_nmds <- ordinate(ps, method="NMDS", distance=bray, trymax=200)
p_nmds <- plot_ordination(ps, ord_nmds, color="Group") +
  geom_point(size=3) +
  theme_minimal() +
  ggtitle("NMDS (Bray–Curtis)")
ggsave(file.path(output_dir, "ordination_nmds_bray.pdf"), p_nmds, width=8, height=6)

# =========================================================
# Community composition plots
# =========================================================

# Collapse to a rank for plotting (Genus by default)
if (!(rank_for_plots %in% colnames(tax_df))) {
  message("Requested rank ", rank_for_plots, " not present. Falling back to organism_name if available.")
  rank_for_plots <- if ("organism_name" %in% colnames(tax_df)) "organism_name" else ""
}
if (rank_for_plots == "") stop("No suitable taxonomy column found for rank plots.")

otu_long <- as.data.frame(otu) %>%
  tibble::rownames_to_column("tax_id") %>%
  pivot_longer(cols=-tax_id, names_to="Sample", values_to="Abundance") %>%
  left_join(tax_df[, c("tax_id", rank_for_plots), drop=FALSE], by="tax_id") %>%
  rename(Rank = all_of(rank_for_plots))

# Replace empty rank labels
otu_long$Rank <- ifelse(is.na(otu_long$Rank) | otu_long$Rank=="", paste0("Unclassified_", otu_long$tax_id), otu_long$Rank)

# Top N taxa overall at chosen rank
rank_totals <- otu_long %>%
  group_by(Rank) %>%
  summarise(Total=sum(Abundance), .groups="drop") %>%
  arrange(desc(Total))

top_ranks <- head(rank_totals$Rank, top_n)

otu_long2 <- otu_long %>%
  mutate(Rank2 = ifelse(Rank %in% top_ranks, Rank, "Other")) %>%
  group_by(Sample, Rank2) %>%
  summarise(Abundance=sum(Abundance), .groups="drop")

p_bar <- ggplot(otu_long2, aes(x=Sample, y=Abundance, fill=Rank2)) +
  geom_bar(stat="identity", position="fill") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle=45, hjust=1)) +
  labs(title=paste0("Relative abundance (Top ", top_n, " @ ", rank_for_plots, ")"),
       y="Proportion", fill=rank_for_plots)

ggsave(file.path(output_dir, paste0("composition_stackedbar_top", top_n, "_", rank_for_plots, ".pdf")),
       p_bar, width=11, height=6)

# =========================================================
# Heatmaps + "cladogram-like" dendrograms of sample similarity
# =========================================================

# Hierarchical clustering of samples using Bray distances
hc_bray <- hclust(as.dist(bray_mat), method="average")
pdf(file.path(output_dir, "samples_dendrogram_bray.pdf"), width=8, height=6)
plot(hc_bray, main="Sample clustering (Bray–Curtis, UPGMA)", xlab="", sub="")
dev.off()

# Heatmap of Bray distances
pdf(file.path(output_dir, "heatmap_bray_distances.pdf"), width=8, height=7)
heatmap(bray_mat, symm=TRUE, main="Bray–Curtis distance heatmap")
dev.off()

# Heatmap of abundance for top taxa (chosen rank)
# Build rank x sample matrix
rank_mat <- otu_long %>%
  group_by(Rank, Sample) %>%
  summarise(Abundance=sum(Abundance), .groups="drop") %>%
  pivot_wider(names_from=Sample, values_from=Abundance, values_fill=0)

# Keep top taxa for readability
rank_mat <- rank_mat %>% left_join(rank_totals, by=c("Rank"="Rank")) %>% arrange(desc(Total))
rank_mat_top <- head(rank_mat, min(50, nrow(rank_mat))) %>% select(-Total)

rmatrix <- as.matrix(rank_mat_top[,-1])
rownames(rmatrix) <- rank_mat_top$Rank

# log transform for visualization stability
rmatrix_log <- log1p(rmatrix)

pdf(file.path(output_dir, paste0("heatmap_abundance_top50_", rank_for_plots, ".pdf")), width=10, height=8)
heatmap(rmatrix_log, main=paste0("Abundance heatmap (log1p, top 50 @ ", rank_for_plots, ")"),
        xlab="Samples", ylab=rank_for_plots, margins=c(10,10))
dev.off()

# =========================================================
# UpSet plot (presence/absence intersections across samples)
# =========================================================

taxa_sets <- lapply(colnames(otu), function(s) rownames(otu)[otu[,s] > presence_threshold])
names(taxa_sets) <- colnames(otu)

# Save the sets (useful for debugging / reuse)
saveRDS(taxa_sets, file.path(output_dir, "taxa_presence_sets_by_sample.rds"))

# Build incidence (taxa x samples) matrix for UpSetR
all_present_taxa <- sort(unique(unlist(taxa_sets)))
incidence <- matrix(0L, nrow=length(all_present_taxa), ncol=length(taxa_sets),
                    dimnames=list(all_present_taxa, names(taxa_sets)))

for (s in names(taxa_sets)) {
  incidence[taxa_sets[[s]], s] <- 1L
}

incidence_df <- as.data.frame(incidence)

# If you have MANY samples, plotting all can be unreadable.
# Option A: plot all samples
# Option B: restrict to top N samples by richness
max_upset_sets <- ncol(incidence_df)  # change if you want a cap, e.g. 20
if (ncol(incidence_df) > max_upset_sets) {
  richness <- colSums(incidence_df)
  keep_sets <- names(sort(richness, decreasing=TRUE))[1:max_upset_sets]
  incidence_df <- incidence_df[, keep_sets, drop=FALSE]
}

# Save incidence matrix (handy for other tools)
write.table(cbind(tax_id=rownames(incidence), incidence),
            file.path(output_dir, "upset_incidence_matrix.tsv"),
            sep="\t", row.names=FALSE, quote=FALSE)

pdf(file.path(output_dir, "upset_presence_intersections.pdf"), width=12, height=7)
UpSetR::upset(
  incidence_df,
  sets = colnames(incidence_df),
  nsets = ncol(incidence_df),
  nintersects = 40,           # show top 40 intersections; adjust
  order.by = "freq",
  keep.order = TRUE,
  mainbar.y.label = paste0("Intersection size (presence > ", presence_threshold, ")"),
  sets.x.label = "Taxa per sample"
)
dev.off()


# =========================================================
# Summary
# =========================================================
sink(file.path(output_dir, "run_summary.txt"))
cat("TRANA ecology summary\n")
cat("=====================\n\n")
cat("Input dir: ", input_dir, "\n")
cat("Output dir:", output_dir, "\n")
cat("Samples:   ", ncol(otu), "\n")
cat("Taxa:      ", nrow(otu), "\n\n")
cat("Per-sample relabund sums (should be ~1):\n")
print(data.frame(Sample=names(sample_sums), SumRelAbund=sample_sums))
cat("\nAlpha diversity saved: alpha_diversity.tsv\n")
cat("Beta distance matrices saved: beta_bray_curtis.tsv, beta_jaccard_pa.tsv\n")
cat("Ordinations saved: ordination_pcoa_bray.pdf, ordination_nmds_bray.pdf\n")
cat("Similarity plots: dendrogram + distance heatmap\n")
cat("Composition plots: stacked bar + abundance heatmap\n")
cat("\nUpSet plot saved: upset_presence_intersections.pdf\n")
sink()

message("Done. Results in: ", output_dir)
