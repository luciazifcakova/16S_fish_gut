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
Most dominat bacterium  that was shared among all samples was Malacoplasma, contributing to a balanced gut ecosystem (e.g. samolon - https://www.nature.com/articles/s41396-023-01379-z). Other dominant bactria, such as Deefgea piscis can produce secondary metabolites that benefit fish health (https://pubmed.ncbi.nlm.nih.gov/36048329/#:~:text=Strain%20D25T%20showed%20the,;%20Rhynchocypris%20kumgangensis;%20Tanakia%20koreensis.) or Cetobacterium somerae, that can improve gut health of fish with its fermaentation products (https://pubmed.ncbi.nlm.nih.gov/34780975/). Overall, these samples looks like heatlhy fish gut samples, as identified  pathogenic bacteria were 46x times less abundant then other bacteria. 


How PDFs Appear on GitHub:

Direct Display (on supported browsers):

PDFs are rendered using the browser's built-in PDF viewer
You can view, scroll, and sometimes search within the PDF
Appears as an embedded viewer within GitHub's interface
What you'll see:

The PDF renders with GitHub's header/footer
Download button available
Page navigation controls
Limitations:

Size Limits:

PDFs over 100 MB cannot be displayed (GitHub prompts download)
Repository file size limit is 100 GB, but individual files over 50 MB trigger warnings
Rendering Issues:

Complex PDFs with special fonts/formatting may not render perfectly
Some interactive elements won't work
Performance may be slow with very large PDFs
Mobile Experience:

Mobile browsers may redirect to download instead of displaying inline
Best Practices for PDFs on GitHub:

Keep PDFs under 50 MB for optimal viewing
Consider alternatives:

For documentation: Use Markdown (.md) files
For large documents: Split into smaller PDFs
For research papers: Provide both PDF and text abstract in README
Add a README note if your repo contains important PDFs, as some users might not realize they can view them inline.
Example Workflow:

bash
# Add PDF to repo
git add document.pdf
git commit -m "Add research paper"
git push origin main
Then users can click the PDF file in the repo to view it directly.

Note: For public repositories, remember that PDFs become publicly accessible too.
for this "https://github.com/luciazifcakova/16S_fish_gut/blob/main/composition_stackedbar_top20_Genus.pdf" I got this error when I want to view pdf in GitHub "Error rendering embedded code

Invalid PDF"
This "Invalid PDF" error is a common issue on GitHub and has several possible causes and solutions:

Common Causes:

Corrupted PDF file - The PDF might be damaged during upload
Incompatible PDF version - GitHub's viewer might not support very old or very new PDF formats
Large file issues - The file appears to be 1.37 MB, which should work, but corruption can still occur
Special characters/encoding - In the filename or within the PDF
Troubleshooting Steps:

1. First, Try Direct Download:

bash
# Use curl or wget to download the file
curl -L -o downloaded.pdf https://github.com/luciazifcakova/16S_fish_gut/raw/main/composition_stackedbar_top20_Genus.pdf

# Or using wget
wget https://github.com/luciazifcakova/16S_fish_gut/raw/main/composition_stackedbar_top20_Genus.pdf
2. Recreate/Re-upload the PDF:

Re-export the PDF from the original source (R, Python, etc.)
Ensure you're using a standard PDF export method
Try saving with different names or to different locations first
3. Check PDF Integrity:

bash
# If you have the file locally
pdfinfo composition_stackedbar_top20_Genus.pdf  # Linux/Mac with poppler
# Or
qpdf --check composition_stackedbar_top20_Genus.pdf
4. Alternative Viewing Methods:

A. Use GitHub's raw URL with browser viewer:

text
https://docs.google.com/viewer?url=https://github.com/luciazifcakova/16S_fish_gut/raw/main/composition_stackedbar_top20_Genus.pdf
B. Use nbviewer (for Jupyter outputs converted to PDF):

text
https://nbviewer.org/github/luciazifcakova/16S_fish_gut/blob/main/composition_stackedbar_top20_Genus.pdf
5. Fix for R Users (likely the source):

If this PDF was created with R/ggplot2:

r
# Try these alternative saving methods:

# Method 1: ggsave with different device
ggsave("composition_stackedbar_top20_Genus.pdf", 
       device = cairo_pdf,  # Better font handling
       width = 10, 
       height = 6)

# Method 2: Use pdf() device directly
pdf("composition_stackedbar_top20_Genus.pdf", 
    width = 10, 
    height = 6,
    useDingbats = FALSE)  # Helps with some rendering issues
print(your_plot)
dev.off()
6. File Repair Options:

Open in Adobe Acrobat and "Save As" to create a fresh copy
Use online repair tools like ilovepdf.com/pdf-repair
Convert to another format and back to PDF
7. GitHub-Specific Solutions:

Delete the file from GitHub and re-upload
Use Git LFS if file corruption occurs during git operations:
bash
git lfs track "*.pdf"
git add .gitattributes
git add composition_stackedbar_top20_Genus.pdf
Temporary Workaround:

Since this appears to be a research/data visualization file, consider:

Upload as PNG/JPEG instead - GitHub displays images flawlessly
Host the PDF elsewhere and link to it in README:

Zenodo, Figshare, or institutional repositories
Google Drive or Dropbox (with public link)
Include the plotting code so others can regenerate the figure
Check if Others Can View It:

Ask collaborators to try viewing the PDF to determine if it's:

A GitHub issue specific to your account/browser
A universal problem with the file
Quick test: Try viewing other PDFs on GitHub to confirm it's file-specific.

If none of these work, the file might be genuinely corrupted and need to be regenerated from the original source code/data.
multiqc plot have found. duplicated reads in my nanopore amplicon data sample, what does it mean?
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
