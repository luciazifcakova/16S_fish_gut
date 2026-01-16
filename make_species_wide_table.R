#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(tools)
})

args <- commandArgs(trailingOnly = TRUE)

rel_dir <- NULL
reads_dir <- NULL
out_prefix <- "species_table"

i <- 1
while (i <= length(args)) {
  if (args[i] == "--rel_dir" && i+1 <= length(args)) { rel_dir <- args[i+1]; i <- i+2
  } else if (args[i] == "--reads_dir" && i+1 <= length(args)) { reads_dir <- args[i+1]; i <- i+2
  } else if (args[i] == "--out_prefix" && i+1 <= length(args)) { out_prefix <- args[i+1]; i <- i+2
  } else { i <- i+1 }
}

if (is.null(rel_dir) || is.null(reads_dir)) {
  cat("Usage:\n")
  cat("  make_species_wide_table.R --rel_dir <pathogens_annotated_dir> --reads_dir <results_dir> [--out_prefix name]\n")
  quit(status=2, save="no")
}

# -----------------------------
# Helpers
# -----------------------------
sample_id_from_rel <- function(fp) {
  bn <- basename(fp)
  sub("_filtered\\.fastq_rel-abundance_with_pathogens\\.tsv$", "", bn)
}

get_read_count <- function(sample_id) {
  fp <- file.path(reads_dir, paste0(sample_id, "_filtered.fastq_read-assignment-distributions.tsv"))
  if (!file.exists(fp)) return(NA_integer_)
  nlines <- length(readLines(fp, warn = FALSE))
  as.integer(max(0, nlines - 1))  # subtract header row
}

first_nonempty <- function(x) {
  x <- x[!is.na(x) & trimws(x) != ""]
  if (length(x) == 0) NA_character_ else x[[1]]
}

# -----------------------------
# Read all annotated rel-abundance files
# -----------------------------
files <- list.files(rel_dir,
                    pattern = "_filtered\\.fastq_rel-abundance_with_pathogens\\.tsv$",
                    full.names = TRUE)

if (length(files) == 0) stop("No *_rel-abundance_with_pathogens.tsv files found in ", rel_dir)

dfs <- lapply(files, function(fp) {
  sid <- sample_id_from_rel(fp)
  df <- read.table(fp, sep="\t", header=TRUE, stringsAsFactors=FALSE, quote="", comment.char="")
  names(df) <- trimws(names(df))

  # Basic checks
  if (!("Species" %in% names(df))) stop("Missing column 'Species' in ", fp)
  if (!("abundance" %in% names(df))) stop("Missing column 'abundance' in ", fp)

  df$Sample <- sid
  df$Species <- trimws(df$Species)
  df
})

all_long <- bind_rows(dfs)

# Remove empty species labels (optional)
all_long <- all_long %>% filter(!is.na(Species), Species != "")

# -----------------------------
# Aggregate duplicates: Species x Sample
# -----------------------------
# If Species repeats within sample (e.g., strain rows), sum abundances.
abund_long <- all_long %>%
  group_by(Species, Sample) %>%
  summarise(abundance = sum(as.numeric(abundance), na.rm=TRUE), .groups="drop")

# -----------------------------
# Build taxonomy/status columns per Species (one row per Species)
# We take the first non-empty value seen across samples.
# -----------------------------
meta_cols <- intersect(
  c("tax_id","organism_name","Genus","Family","Order","Class","Phylum","Kingdom","Domain","pathogen_status"),
  names(all_long)
)

species_meta <- all_long %>%
  group_by(Species) %>%
  summarise(across(all_of(meta_cols), first_nonempty), .groups="drop")

# -----------------------------
# Pivot to wide: Species rows, Sample columns
# -----------------------------
wide <- abund_long %>%
  tidyr::pivot_wider(names_from = Sample, values_from = abundance, values_fill = 0)

# Join metadata columns on the left
wide2 <- species_meta %>%
  left_join(wide, by="Species") %>%
  relocate(Species)

# Optional: order sample columns naturally (SAMPLE_1, SAMPLE_2, ...)
sample_cols <- setdiff(colnames(wide2), c("Species", meta_cols))
# keep as-is if you prefer original order; otherwise sort:
sample_cols_sorted <- sample_cols[order(sample_cols)]
wide2 <- wide2 %>% select(Species, all_of(meta_cols), all_of(sample_cols_sorted))

# -----------------------------
# Write outputs
# -----------------------------
out_wide <- paste0(out_prefix, "_species_x_samples_abundance.tsv")
write.table(wide2, out_wide, sep="\t", row.names=FALSE, quote=FALSE)
message("Wrote: ", out_wide)

# Sample read counts as separate table (sample-level metadata)
samples <- sort(unique(abund_long$Sample))
read_counts <- data.frame(
  Sample = samples,
  ReadCount = vapply(samples, get_read_count, integer(1)),
  stringsAsFactors = FALSE
)

out_reads <- paste0(out_prefix, "_sample_read_counts.tsv")
write.table(read_counts, out_reads, sep="\t", row.names=FALSE, quote=FALSE)
message("Wrote: ", out_reads)
