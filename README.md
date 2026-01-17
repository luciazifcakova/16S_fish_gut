# 16S_fish_gut

Full-length 16S in gut microbiome provides higher taxonomic resolution (often to species; sometimes strains). Short regions (esp. V4) frequently collapse multiple species into one genus-level call, while full-length provides more informative sites across the gene and can separate closely related taxa better. This is a recurring conclusion across benchmarking studies. 

https://github.com/genomic-medicine-sweden/TRANA pipeline using Emu classifier vs https://epi2me.nanoporetech.com/epi2me-docs/workflows/wf-16s/ using minimap2:
The Emu classifier is specifically designed to generate accurate species-level abundance profiles from full-length 16S Nanopore reads by using an expectation–maximization (EM) algorithm to refine taxonomic assignments based on the collective evidence from all reads (https://pmc.ncbi.nlm.nih.gov/articles/PMC9939874/). In contrast to a simple alignment approach like minimap2, which only maps reads to reference sequences without resolving ambiguous matches, Emu iteratively adjusts the probability that each read arises from each candidate taxon, reducing false positives and improving abundance estimates. Benchmarking on simulated and mock communities shows that Emu produces lower relative abundance error and far fewer incorrect species calls than minimap2 alone, because it balances true positive detection with false positive suppression through its probabilistic model rather than relying solely on raw alignments.

My pipeline logic:
1. Check QC - FastQC, Nanoplot, MultiQC, Filtlong
2. EMU classifier with RiboGrove curated database
3. relative abundace tables
4. Krona - relative abundace results are displayed with Krona
5. pathogen detection via list comparison, see NEMESISdb below 
6. diversity indices and ordination plots, final tables (build Docker image)

I have used with pipeline RiboGrove - A database that only contains full-length prokaryotic 16S rRNA sequences extracted from completely assembled genomes — excellent for phylogenetic or genome-linked marker studies. (https://www.sciencedirect.com/science/article/pii/S0923250822000171).

Results:

Community composition differed substantially among samples, with Bray–Curtis distances revealing clear clustering patterns. Ordination and hierarchical clustering consistently identified groups of samples with similar relative-abundance profiles. Presence–absence analysis using UpSet plots indicated the absence of a large universal core community, instead revealing a modular structure with taxa shared among subsets of samples. This suggests high community turnover and potential environmental or host-associated filtering shaping taxonomic composition. Across samples, we observed a relatively small but consistent core of taxa present in all samples, accompanied by a large number of low-frequency taxa that were restricted to few samples. This pattern indicates a stable community backbone with flexible peripheral membership, typical of host-associated or environmentally structured microbial communities.
Most dominat bacterium  that was shared among all samples was Malacoplasma, contributing to a balanced gut ecosystem (e.g. samolon - https://www.nature.com/articles/s41396-023-01379-z). Other dominant bactria, such as Deefgea piscis can produce secondary metabolites that benefit fish health (https://pubmed.ncbi.nlm.nih.gov/36048329/#:~:text=Strain%20D25T%20showed%20the,;%20Rhynchocypris%20kumgangensis;%20Tanakia%20koreensis.) or Cetobacterium somerae, that can improve gut health of fish with its fermaentation products (https://pubmed.ncbi.nlm.nih.gov/34780975/). Overall, these samples looks like heatlhy fish gut samples, as identified  pathogenic bacteria made up max. 2.7% ofidentified bacteria in the sample. Sample 25 had highest observed biodiversity, while sample 10 and 23 lowest. Less diverse community, dominated by few taxa was indicated by very low Shannon (overall diversity, richness + evenness), Pielou (evenness  - how equal abundances are) and Simpson index (dominance of species, weighted toward common species) were all below 0.2 in samples 10, 16, 22, 4. This can suggest either naturally low diversity becouse of envrionmental factor, such as diet (carnivora have less diverse microbiome) or treatment (e.g. antibiotics, as only in sample 4 pathogens were confirmed in 0.12% relative abundace). On the other hand, samples 15 and 35 had all three indices amongst highest from all samples, which can translates to highly diverse community that is distributed evenly, so it may suggest healthy fish with diverse diet. There is certain grouping patter recognized on NMDS and PCoA (Bray-Curtis distance) plots  that is not caused by presence of known pathogens, so other factor play a role. 

Comments on data quality:

31 samples had higher than 20% read duplication level that can either mean low biological diversity or techincal errors. However, even the sample 25 with highest bacterial species diversity had 40% of duplication level, it is possible that PCR over-amplified some templates more then others or that flow cell was overload followed by re-sequencing, hence it can skew abundance and biodiversity estimates. 

pathogenic bacteria lists:

https://www.sciencedirect.com/science/article/pii/S235234092500856X
NEMESISdb is a set of three curated 16S rRNA full length sequence datasets enabling the identification and tracking of potentially pathogenic bacteria (PPB) across human, fish and crustacean hosts and helping reveal factors that influence their dynamics. A list of pathogenic bacteria for humans, fishes, and crustaceans from various studies and pathogen detection pipeline such as 16SPIP, FAPROTAX, MPD and MBPD. Full length 16S rRNA gene sequences of each of the pathogenic bacteria of the list was downloaded from the SILVA 138.2 SSU Ref NR99 bacterial database in order to obtain three pathogenic reference datasets for humans, fishes, and crustaceans, respectively. Lastly, each dataset was curated with homemade scripts to remove all sequences wrongly assigned at the species taxonomic level in SILVA 138.2 SSU Ref NR99.
https://doi.org/10.1016/j.resmic.2022.103936.

Suggestion for future analyses:

Building on this high-resolution full-length 16S dataset, the next analytical steps with the greatest commercial value include establishing baseline gut microbiome profiles and offering monitoring to detect temporal deviations associated with management, diet, or environmental changes. Diversity metrics and pathogen screening results can be integrated into composite gut-health and risk indices, enabling intuitive benchmarking across samples and time points. 

Add functional interpretation without shotgun metagenomics
This is a high-margin move.
Options
FAPROTAX-like functional inference (carefully framed)
Trait-based grouping:
fermenters
vitamin producers (e.g. Cetobacterium)
mucin degraders
Known metabolite producers (literature-based)
Why
Answers “what are they doing?” without expensive WGS
Clients don’t need KEGG pathways — they need functional narratives

Shotgun metagenomics (selected cases)
Resistome screening
Virome (later stage)
Host gene expression (advanced clients)


Expanding pathogen detection into threshold-based early-warning frameworks and incorporating functional trait inference can further translate taxonomic data into actionable biological insight. 

Finally, aggregating results across projects to construct reference datasets and standardized reporting dashboards supports subscription-based services, client lock-in, and scalable decision-support products for aquaculture stakeholders.

1. 
