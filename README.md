# 16S_fish_gut

Full-length 16S in gut microbiome provides higher taxonomic resolution (often to species; sometimes strain “hints”). Short regions (esp. V4) frequently collapse multiple species into one genus-level call, while full-length provides more informative sites across the gene and can separate closely related taxa better. This is a recurring conclusion across benchmarking studies. 

Pipeline logic:
https://github.com/genomic-medicine-sweden/TRANA
1. Check QC - FastQC, Nanoplot, MultiQC, Filtlong
2. EMU - relative abundance estimator for 16S genomic sequences. The method is optimized for error-prone full-length reads and is capable of accurate microbial community profiling while obtaining fewer false positives and false negatives than alternative methods. (https://www.nature.com/articles/s41592-022-01520-4)
3. Krona - relative abundace results are displayed with Krona

I have used with pipeline RiboGrove - A database that only contains full-length prokaryotic 16S rRNA sequences extracted from completely assembled genomes — excellent for phylogenetic or genome-linked marker studies. (https://www.sciencedirect.com/science/article/pii/S0923250822000171).

 
 Results from both ONT and Illumina were merged and analyzed in R (v. 4.2.0)57, mainly through Phyloseq (v. 1.42.0)58 for data management, ANCOM-BC (v. 2.0.1)59 for differential abundance analysis (prevalence cutoff of 10%, adjusting significance by Holm-Bonferroni60) and microbiome (v. 1.20.0)61 for centered log-ratio abundance normalization (CLR). In order to assess -diversity differences, a PERMANOVA analysis through adonis262, using a multi-dimensional scaling (MDS) and the Jensen-Shannon distance (JSD), was performed. Additionally, pairwise comparisons were conducted using Wilcoxon rank-sum tests (WRST), adjusting significance for multiple comparisons using Holm-Bonferroni. Significance values across analyses are represented as * (), ** () or *** ().


Results:
Community composition differed substantially among samples, with Bray–Curtis distances revealing clear clustering patterns. Ordination and hierarchical clustering consistently identified groups of samples with similar relative-abundance profiles. Presence–absence analysis using UpSet plots indicated the absence of a large universal core community, instead revealing a modular structure with taxa shared among subsets of samples. This suggests high community turnover and potential environmental or host-associated filtering shaping taxonomic composition. Across samples, we observed a relatively small but consistent core of taxa present in all samples, accompanied by a large number of low-frequency taxa that were restricted to few samples. This pattern indicates a stable community backbone with flexible peripheral membership, typical of host-associated or environmentally structured microbial communities.
Most dominat bacterium  that was shared among all samples was Malacoplasma, contributing to a balanced gut ecosystem (e.g. samolon - https://www.nature.com/articles/s41396-023-01379-z). Other dominant bactria, such as Deefgea piscis can produce secondary metabolites that benefit fish health (https://pubmed.ncbi.nlm.nih.gov/36048329/#:~:text=Strain%20D25T%20showed%20the,;%20Rhynchocypris%20kumgangensis;%20Tanakia%20koreensis.) or Cetobacterium somerae, that can improve gut health of fish with its fermaentation products (https://pubmed.ncbi.nlm.nih.gov/34780975/). Overall, these samples looks like heatlhy fish gut samples, as identified  pathogenic bacteria were 46x times less abundant then other bacteria. Sample 25 had highest observed biodiversity, while sample 10 and 23 lowest. Less diverse community, dominated by few taxa was indicated by very low Shannon (overall diversity, richness + evenness), Pielou (evenness  - how equal abundances are) and Simpson index (dominance of species, weighted toward common species) were all below 0.2 in samples 10, 16, 22, 4. This can suggest either naturally low diversity becouse of envrionmental factor, such as diet (carnivora have less diverse microbiome) or treatment (e.g. antibiotics, as only in sample 4 pathogens were confirmed in 0.12% relative abundace). On the other hand, samples 15 and 35 had all three indices amongst highest from all samples, which can translates to highly diverse community that is distributed evenly, so it may suggest healthy fish with diverse diet. There is certain grouping patter recognized on NMDS and PCoA (Bray-Curtis distance) plots  that is not caused by presence of known pathogens, so other factor play a role. 


duplicated reads in my nanopore amplicon data sample, what does it mean?
Duplicated reads in nanopore amplicon data from MultiQC is a significant concern that indicates something went wrong with your library preparation, sequencing, or experimental design. Here's what it means and why it's problematic:

What "Duplicated Reads" Means:

MultiQC is identifying read sequences that are exact or near-exact duplicates across your dataset. For Nanopore amplicon sequencing, this typically means:

PCR duplication artifacts (most common) - The same original DNA molecule was amplified multiple times
Sequence carryover/cross-contamination between runs
Technical artifacts from Nanopore chemistry
Why This Is Concerning for Nanopore Amplicon Data:

Expected vs. Unexpected:

Expected: Some duplication in amplicon sequencing (since you're amplifying specific regions)
Unexpected: High duplication rates (typically >20-30% is concerning for amplicon)
Specific Risks for Nanopore:

PCR Bias Amplification: If you used PCR, some templates amplify more efficiently
Chimera Formation: PCR can create artificial recombinants
Quantitative Distortion: Duplicates skew abundance estimates in microbial community analysis
Reduced Diversity Coverage: You're sequencing the same molecules repeatedly instead of capturing diversity
Common Causes in Nanopore Amplicon Workflows:

1. Library Preparation Issues:

Excessive PCR cycles (common with 16S/ITS amplicon protocols)
Low input DNA leading to over-amplification
PCR plateau phase reached during amplification
2. Sequencing Issues:

Low complexity library - not enough unique starting molecules
Flow cell overloading followed by re-sequencing
Adapter dimers being sequenced repeatedly
3. Experimental Design Issues:

Too few cells/microbes in starting sample
Sample degradation before PCR
Primer bias favoring certain sequences

#made pathogenic bacteria lists
https://www.sciencedirect.com/science/article/pii/S235234092500856X
NEMESISdb is a set of three curated 16S rRNA full length sequence datasets enabling the identification and tracking of potentially pathogenic bacteria (PPB) across human, fish and crustacean hosts and helping reveal factors that influence their dynamics.
•
NEMESISdb can be directly and easily used in blast or in classifier softwares for fast detection of PPB in 16S rRNA gene metabarcoding or metagenomic data.

We constructed a list of pathogenic bacteria for humans, fishes, and crustaceans from various studies and pathogen detection pipeline such as 16SPIP, FAPROTAX, MPD and MBPD. Afterward, full length 16S rRNA gene sequences of each of the pathogenic bacteria of the list was downloaded from the SILVA 138.2 SSU Ref NR99 bacterial database in order to obtain three pathogenic reference datasets for humans, fishes, and crustaceans, respectively. Lastly, each dataset was curated with homemade scripts to remove all sequences wrongly assigned at the species taxonomic level in SILVA 138.2 SSU Ref NR99.
https://doi.org/10.1016/j.resmic.2022.103936.
