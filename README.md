# 16S_fish_gut

Full-length 16S in gut microbiome: pros
Higher taxonomic resolution (often to species; sometimes strain “hints”).
Short regions (esp. V4) frequently collapse multiple species into one genus-level call, while full-length provides more informative sites across the gene and can separate closely related taxa better. This is a recurring conclusion across benchmarking studies. 

Johnson, J.S., Spakowicz, D.J., Hong, BY. et al. Evaluation of 16S rRNA gene sequencing for species and strain-level microbiome analysis. Nat Commun 10, 5029 (2019). https://doi.org/10.1038/s41467-019-13036-1

Buetas, E., Jordán-López, M., López-Roldán, A. et al. Full-length 16S rRNA gene sequencing by PacBio improves taxonomic resolution in human microbiome samples. BMC Genomics 25, 310 (2024). https://doi.org/10.1186/s12864-024-10213-5

Szoboszlay M, Schramm L, Pinzauti D, Scerri J, Sandionigi A, Biazzo M. Nanopore Is Preferable over Illumina for 16S Amplicon Sequencing of the Gut Microbiota When Species-Level Taxonomic Classification, Accurate Estimation of Richness, or Focus on Rare Taxa Is Required. Microorganisms. 2023 Mar 21;11(3):804. doi: 10.3390/microorganisms11030804. PMID: 36985377; PMCID: PMC10059749.

More accurate relative abundance for some taxa when handled correctly.
Full-length reads also capture intra-genomic 16S copy variation; when you cluster/denoise appropriately, that variation can help classification rather than harm it. 

Better “portability” across studies in principle (less dependent on which hypervariable region you picked).
Partial-region choice matters a lot (V1–V2 vs V3–V4 vs V4 can shift observed composition). Full-length reduces this particular axis of study-to-study variability.

Sharma A, Andreani NA, Keller L, Herpertz-Dahlmann B, Seitz J, Baines JF, Dempfle A. Comparison of 16S ribosomal RNA hypervariable regions in microbiome studies of anorexia nervosa. Front Microbiol. 2025 Sep 26;16:1665847. doi: 10.3389/fmicb.2025.1665847. PMID: 41098530; PMCID: PMC12519842.

Marcus J. Claesson, Qiong Wang, Orla O'Sullivan, Rachel Greene-Diniz, James R. Cole, R. Paul Ross, Paul W. O'Toole, Comparison of two next-generation sequencing technologies for resolving highly complex microbiota composition using tandem variable 16S rRNA gene regions, Nucleic Acids Research, Volume 38, Issue 22, 1 December 2010, Page e200, https://doi.org/10.1093/nar/gkq873

In at least one diet-intervention mouse gut study, full-length vs V4 affected interpretation to some degree, even when broad community trends were similar. 

Katiraei S, Anvar Y, Hoving L, Berbée JFP, van Harmelen V, Willems van Dijk K. Evaluation of Full-Length Versus V4-Region 16S rRNA Sequencing for Phylogenetic Analysis of Mouse Intestinal Microbiota After a Dietary Intervention. Curr Microbiol. 2022 Jul 30;79(9):276. doi: 10.1007/s00284-022-02956-9. PMID: 35907023; PMCID: PMC9338901.

Human microbiome comparisons show full-length improves taxonomic resolution power vs short-read regions. 

Buetas, E., Jordán-López, M., López-Roldán, A. et al. Full-length 16S rRNA gene sequencing by PacBio improves taxonomic resolution in human microbiome samples. BMC Genomics 25, 310 (2024). https://doi.org/10.1186/s12864-024-10213-5

Some gut-focused benchmarks argue Nanopore full-length is preferable when the priority is species-level classification / rare taxa / richness estimation, while Illumina is strong when you need ASV-style resolution and communities with many unknown species.



RiboGrove
A database that only contains full-length prokaryotic 16S rRNA sequences extracted from completely assembled genomes — excellent for phylogenetic or genome-linked marker studies.

Maxim A. Sikolenko, Leonid N. Valentovich,
RiboGrove: a database of full-length prokaryotic 16S rRNA genes derived from completely assembled genomes,
Research in Microbiology,
Volume 173, Issues 4–5,
2022,
103936,



Aja-Macaya, P., Conde-Pérez, K., Trigo-Tasende, N. et al. Nanopore full length 16S rRNA gene sequencing increases species resolution in bacterial biomarker discovery. Sci Rep 15, 26486 (2025). https://doi.org/10.1038/s41598-025-10999-8

 Additionally, Duplex Tools (v. 0.2.9)48 was used to detect and remove reads with mid-strand adapters. Host contamination was assessed with Kraken2 using its Standard 64Gb database (https://benlangmead.github.io/aws-indexes/k2)49. Lastly, reads were identified using Emu (v. 3.4.5)43 with its Default database (rrnDB v. 5.650 combined with NCBI 16S RefSeq51,52) and SILVA (v. 138.1)53,54.
 
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
