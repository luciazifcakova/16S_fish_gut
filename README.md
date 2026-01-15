# 16S_fish_gut

Full-length 16S in gut microbiome provides higher taxonomic resolution (often to species; sometimes strain “hints”). Short regions (esp. V4) frequently collapse multiple species into one genus-level call, while full-length provides more informative sites across the gene and can separate closely related taxa better. This is a recurring conclusion across benchmarking studies. 

Pipeline logic:

RiboGrove - A database that only contains full-length prokaryotic 16S rRNA sequences extracted from completely assembled genomes — excellent for phylogenetic or genome-linked marker studies. (https://www.sciencedirect.com/science/article/pii/S0923250822000171)




 
 Results from both ONT and Illumina were merged and analyzed in R (v. 4.2.0)57, mainly through Phyloseq (v. 1.42.0)58 for data management, ANCOM-BC (v. 2.0.1)59 for differential abundance analysis (prevalence cutoff of 10%, adjusting significance by Holm-Bonferroni60) and microbiome (v. 1.20.0)61 for centered log-ratio abundance normalization (CLR). In order to assess -diversity differences, a PERMANOVA analysis through adonis262, using a multi-dimensional scaling (MDS) and the Jensen-Shannon distance (JSD), was performed. Additionally, pairwise comparisons were conducted using Wilcoxon rank-sum tests (WRST), adjusting significance for multiple comparisons using Holm-Bonferroni. Significance values across analyses are represented as * (), ** () or *** ().



Kraken2 uses k-mer exact matches
Nanopore errors break k-mers
Full-length 16S benefits from alignment-based methods


###########
use Emu classifier

Curry KD, et al. Emu: species-level microbial community profiling of full-length 16S rRNA Oxford Nanopore sequencing data. Nature Methods. 2022. Emu uses an expectation-maximization algorithm tailored for long-read 16S profiling, yielding accurate taxonomic abundance profiles with fewer false positives/negatives than alternatives.
###########



ISSN 0923-2508,


#made pathogenic bacteria lists
https://www.sciencedirect.com/science/article/pii/S235234092500856X
NEMESISdb is a set of three curated 16S rRNA full length sequence datasets enabling the identification and tracking of potentially pathogenic bacteria (PPB) across human, fish and crustacean hosts and helping reveal factors that influence their dynamics.
•
NEMESISdb can be directly and easily used in blast or in classifier softwares for fast detection of PPB in 16S rRNA gene metabarcoding or metagenomic data.

We constructed a list of pathogenic bacteria for humans, fishes, and crustaceans from various studies and pathogen detection pipeline such as 16SPIP, FAPROTAX, MPD and MBPD. Afterward, full length 16S rRNA gene sequences of each of the pathogenic bacteria of the list was downloaded from the SILVA 138.2 SSU Ref NR99 bacterial database in order to obtain three pathogenic reference datasets for humans, fishes, and crustaceans, respectively. Lastly, each dataset was curated with homemade scripts to remove all sequences wrongly assigned at the species taxonomic level in SILVA 138.2 SSU Ref NR99.
https://doi.org/10.1016/j.resmic.2022.103936.
