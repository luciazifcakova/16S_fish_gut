#!/bin/bash
#SBATCH --job-name=fish_trana2
#SBATCH --partition=compute
#SBATCH --time=3-0
#SBATCH --mem=120G
#SBATCH --cpus-per-task=20
#SBATCH --mail-user=lucia.zifcakova@oist.jp
#SBATCH --mail-type=BEGIN,FAIL,END 
#SBATCH --output=./fish_trana2.out

ml bioinfo-ugrp-modules 
ml DebianMed
ml Nextflow2

eval "$(conda shell.bash hook)"

# Activate your desired Conda environment
conda activate krona

export NXF_SINGULARITY_CACHEDIR=/flash/MillerU/seqme_test/.singularity_cache
export SINGULARITY_CACHEDIR=/flash/MillerU/seqme_test/.singularity_cache
export NXF_SINGULARITY_TMPDIR=/flash/MillerU/seqme_test/tmp
export TMPDIR=/flash/MillerU/seqme_test/tmp
export NXF_HOME=/flash/MillerU/seqme_test/.nextflow

mkdir -p "$NXF_SINGULARITY_TMPDIR"

nextflow run luciazifcakova/TRANA_translate_modified -r main \
  --input /flash/MillerU/seqme_test/fish/samplesheet.csv \
  --outdir /flash/MillerU/seqme_test/fish_trana3 \
  --db /bucket/MillerU/Zifcakova/seqme_test/ribogrove/ribogrove_emu_db \
  --seqtype map-ont \
  --max_time "90h" \
  --krona_taxonomy_tab /flash/MillerU/seqme_test/krona_taxonomy/taxonomy.tab \
   -profile singularity,oist 
