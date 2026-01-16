#!/bin/bash
#SBATCH --job-name=fish_wide_table
#SBATCH --partition=compute
#SBATCH --time=1-0
#SBATCH --mem=12G
#SBATCH --cpus-per-task=4
#SBATCH --mail-user=lucia.zifcakova@oist.jp
#SBATCH --mail-type=BEGIN,FAIL,END 
#SBATCH --output=./fish_wide_table.out

ml bioinfo-ugrp-modules
ml DebianMed
ml R/4.3.1

Rscript make_species_wide_table.R \
  --rel_dir /flash/MillerU/seqme_test/pathogens_annotated \
  --reads_dir /flash/MillerU/seqme_test/fish_trana/results \
  --out_prefix /flash/MillerU/seqme_test/fish
