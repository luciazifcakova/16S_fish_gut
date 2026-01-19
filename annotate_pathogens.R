#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(dplyr)
})

# -----------------------------
# Args
# -----------------------------
args <- commandArgs(trailingOnly = TRUE)

infile <- NULL
pathogen_file <- NULL
outdir <- "."
mode <- "exact"          # exact | prefix | genus
species_col <- "Species" # change if your column name differs
genus_col <- "Genus"     # used only for mode=genus

i <- 1
while (i <= length(args)) {
  if (args[i] == "--in" && i + 1 <= length(args)) {
    infile <- args[i + 1]; i <- i + 2
  } else if (args[i] == "--pathogens" && i + 1 <= length(args)) {
    pathogen_file <- args[i + 1]; i <- i + 2
  } else if (args[i] == "--outdir" && i + 1 <= length(args)) {
    outdir <- args[i + 1]; i <- i + 2
  } else if (args[i] == "--mode" && i + 1 <= length(args)) {
    mode <- args[i + 1]; i <- i + 2
  } else if (args[i] == "--species_col" && i + 1 <= length(args)) {
    species_col <- args[i + 1]; i <- i + 2
  } else if (args[i] == "--genus_col" && i + 1 <= length(args)) {
    genus_col <- args[i + 1]; i <- i + 2
  } else {
    i <- i + 1
  }
}

if (is.null(infile) || is.null(pathogen_file)) {
  cat("Usage:\n")
  cat("  annotate_pathogens.R --in <sample.tsv> --pathogens <pathogens.txt> [--outdir <dir>] [--mode exact|prefix|genus]\n")
  cat("                     [--species_col Species] [--genus_col Genus]\n")
  quit(status = 2, save = "no")
}

dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

# -----------------------------
# Read inputs
# -----------------------------
abund <- read.table(
  infile,
  sep = "\t",
  header = TRUE,
  stringsAsFactors = FALSE,
  quote = "",
  comment.char = ""
)

pathogens <- readLines(pathogen_file, warn = FALSE)
pathogens <- trimws(pathogens)
pathogens <- pathogens[nzchar(pathogens)]

# Basic column checks
if (!(species_col %in% names(abund))) {
  stop("Column '", species_col, "' not found in input: ", infile,
       "\nAvailable columns: ", paste(names(abund), collapse = ", "))
}
if (mode == "genus" && !(genus_col %in% names(abund))) {
  stop("Mode=genus requires column '", genus_col, "' in input: ", infile,
       "\nAvailable columns: ", paste(names(abund), collapse = ", "))
}

# Normalize whitespace in Species column
abund[[species_col]] <- trimws(abund[[species_col]])

# -----------------------------
# Annotate
# -----------------------------
flag_exact <- function(x) x %in% pathogens

flag_prefix <- function(x) {
  # Treat pathogen entries as species strings like "Aeromonas salmonicida"
  # Flag if x starts with any pathogen string (covers subspecies/strains)
  sapply(x, function(one) any(startsWith(one, pathogens)))
}

flag_genus <- function(genus_vec) {
  pathogen_genera <- unique(sub(" .*", "", pathogens))
  genus_vec %in% pathogen_genera
}

abund <- abund %>%
  mutate(
    pathogen_status = dplyr::case_when(
      mode == "exact"  & flag_exact(.data[[species_col]]) ~ "pathogen",
      mode == "prefix" & flag_prefix(.data[[species_col]]) ~ "pathogen",
      mode == "genus"  & flag_genus(.data[[genus_col]]) ~ "pathogen",
      TRUE ~ NA_character_
    )
  )

# -----------------------------
# Output naming
# -----------------------------
base <- tools::file_path_sans_ext(basename(infile))
outfile <- file.path(outdir, paste0(base, "_with_pathogens.tsv"))

write.table(
  abund,
  file = outfile,
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)

cat("Wrote:", outfile, "\n")
