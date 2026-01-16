#!/bin/bash
#SBATCH -J trana_ecology
#SBATCH -p compute
#SBATCH -c 8
#SBATCH --mem=32G
#SBATCH -t 04:00:00
#SBATCH -o logs/ecology_trana.%j.out
#SBATCH -e logs/ecology_trana.%j.err

ml bioinfo-ugrp-modules 
ml DebianMed
ml singularity

set -euo pipefail
mkdir -p logs

IMG="/flash/MillerU/seqme_test/r_ecology_sandbox"
INPUT="/flash/MillerU/seqme_test/fish_trana/results"
OUT="/flash/MillerU/seqme_test/ecology_out"

mkdir -p "$OUT"

singularity run \
  --bind "$INPUT":/in \
  --bind "$OUT":/out \
  "$IMG" \
  --input_dir /in \
  --output_dir /out \
  --rank Genus \
  --top_n 20 \
  --presence_threshold 1e-4 \
  --max_upset_sets 35
