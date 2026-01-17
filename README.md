# 16S_fish_gut

Pouzitie celej dlzky 16S markeru pri analýze črevného mikrobiómu poskytuje vyššie taxonomické rozlíšenie (často na úroveň druhu). Krátke amplikónové oblasti (najmä V4) často zlučujú viacero druhov do jedného rodu, zatiaľ čo cela 16S obsahuje viac informatívnych miest pozdĺž celého markeru a umožňuje lepšie rozlíšenie blízko príbuzných taxónov. Tento záver sa opakovane potvrdzuje v porovnávacích (benchmarking) štúdiách.

Porovnanie pipeline
[https://github.com/genomic-medicine-sweden/TRANA](https://github.com/genomic-medicine-sweden/TRANA) používajúcej klasifikátor EMU
vs.
[https://epi2me.nanoporetech.com/epi2me-docs/workflows/wf-16s/](https://epi2me.nanoporetech.com/epi2me-docs/workflows/wf-16s/) používajúcej minimap2:

Klasifikátor EMU je špecificky navrhnutý na generovanie presných profilov relatívnej abundancie na úrovni druhov z celej 16S pri Nanopore sekvenovani pomocou algoritmu očakávanej–maximalizácia, ktorý spresňuje taxonomické priradenie na základe kolektívneho dôkazu zo všetkých readov ([https://pmc.ncbi.nlm.nih.gov/articles/PMC9939874/](https://pmc.ncbi.nlm.nih.gov/articles/PMC9939874/)). Na rozdiel od jednoduchého prístup založeného na zarovnaní, ako je minimap2, ktorý mapuje čítania na referenčné sekvencie bez riešenia nejednoznačných zhôd, EMU iteratívne upravuje pravdepodobnosť, že dané čítanie pochádza z konkrétneho kandidátneho taxónu. Tým znižuje počet falošne pozitívnych priradení a zlepšuje odhady abundancie. Benchmarky na simulovaných a „mock“ komunitách ukazujú, že EMU dosahuje nižšiu chybu relatívnej abundancie a výrazne menej nesprávnych druhových priradení než samotný minimap2, pretože využíva pravdepodobnostný model namiesto spoliehania sa výlučne na surové zarovnania.

---

## Logika pipeline:

1. Kontrola kvality (QC) – FastQC, NanoPlot, MultiQC, Filtlong
2. Klasifikácia pomocou EMU s kurátorovanou databázou RiboGrove
3. Generovanie tabuliek relatívnej abundancie
4. Vizualizácia relatívnej abundancie pomocou Krona
5. Detekcia patogénov porovnaním so zoznamami (viď NEMESISdb nižšie)
6. Výpočet diverzitných indexov, ordinačné analýzy a finálne tabuľky (Docker image)

---

Implementovala som modifikovanú verziu pipeline TRANA
[https://github.com/luciazifcakova/TRANA_translate_modified](https://github.com/luciazifcakova/TRANA_translate_modified)
pre full-length Nanopore 16S rRNA dáta a rozšírila ju o vlastné moduly pre postprocesing a ekologickú analýzu. Okrem taxonomického profilovania pomocou klasifikátora EMU s kurátorovanou databázou RiboGrove, ktorá obsahuje full-length prokaryotické 16S rRNA sekvencie extrahované z kompletne zostavených genómov ([https://www.sciencedirect.com/science/article/pii/S0923250822000171](https://www.sciencedirect.com/science/article/pii/S0923250822000171)), som vyvinula reprodukovateľné downstream workflowy na agregáciu kontroly kvality, tvorbu tabuliek abundancie, analýzu alfa a beta diverzity, ordinačné analýzy, zhlukovanie, patogénovo orientované sub-analýzy a interaktívne vizualizácie. Postprocesingový workflow je kontajnerizovaný pomocou Dockeru s fixnými verziami softvéru a navrhnutý na škálovateľné spúšťanie na HPC systémoch cez Slurm, čo umožňuje reprodukovateľnú analýzu veľkých kohort mikrobiómov.

---

## Zoznamy patogénnych baktérií:

[https://www.sciencedirect.com/science/article/pii/S235234092500856X](https://www.sciencedirect.com/science/article/pii/S235234092500856X)

NEMESISdb je súbor troch kurátorovaných databáz full-length 16S rRNA sekvencií, ktoré umožňujú identifikáciu a sledovanie potenciálne patogénnych baktérií (PPB) u ľudí, rýb a kôrovcov a pomáhajú odhaľovať faktory ovplyvňujúce ich dynamiku. Zoznam patogénnych baktérií pre ľudí, ryby a kôrovce bol zostavený z viacerých štúdií a pipeline na detekciu patogénov, ako sú 16SPIP, FAPROTAX, MPD a MBPD. Full-length 16S rRNA sekvencie jednotlivých patogénnych baktérií boli stiahnuté z databázy SILVA 138.2 SSU Ref NR99 s cieľom vytvoriť tri referenčné patogénne databázy pre ľudí, ryby a kôrovce. Následne boli databázy kurátorované pomocou vlastných skriptov na odstránenie sekvencií nesprávne priradených na úrovni druhu v databáze SILVA 138.2 SSU Ref NR99.
[https://doi.org/10.1016/j.resmic.2022.103936](https://doi.org/10.1016/j.resmic.2022.103936)

---

## Validácie a obmedzenia:

Hoci full-length 16S zlepšuje taxonomické rozlíšenie, odhady relatívnej abundancie sú stále ovplyvnené PCR amplifikačným biasom, variabilitou počtu kópií rRNA génu a úplnosťou databáz. EMU redukuje počet falošne pozitívnych priradení v porovnaní s priamym zarovnávaním (napr. minimap2), no nedokáže úplne rozlíšiť taxóny, ktoré chýbajú alebo sú nesprávne reprezentované v referenčných databázach. Z tohto dôvodu sú odhady abundancie interpretované porovnávacím spôsobom medzi vzorkami, nie ako absolútne hodnoty, a nízkoabundantné taxóny sú zachované v downstream ekologických analýzach. Diverzitné metriky boli vypočítané z tabuliek relatívnej abundancie odvodených z EMU odhadov; interpretácie sa preto zameriavajú na štruktúru komunít a porovnávacie trendy, nie na absolútnu mikrobiálnu záťaž.

V 31 vzorkách bola pozorovaná úroveň duplicity čítaní vyššia než 20 %, čo môže naznačovať buď nízku biologickú diverzitu, alebo technické artefakty. Duplicitné čítania sú však očakávané pri PCR amplifikovaných vzorkách a metriky duplicity z FastQC je potrebné interpretovať opatrne, keďže FastQC nie je primárne navrhnutý pre Nanopore dáta.

---

## Výsledky:

Zloženie mikrobiálnych komunít sa medzi vzorkami výrazne líšilo, pričom Bray–Curtis vzdialenosti odhalili jasné zhlukovacie vzory. Ordinačné a hierarchické zhlukovacie analýzy konzistentne identifikovali skupiny vzoriek s podobnými profilmi relatívnej abundancie. Analýza prítomnosti/neprítomnosti pomocou UpSet grafov ukázala absenciu veľkého univerzálneho jadra komunity a namiesto toho odhalila modulárnu štruktúru s taxónmi zdieľanými medzi podmnožinami vzoriek. To naznačuje vysoký obrat komunít a potenciálne environmentálne alebo hostiteľsky podmienené filtre formujúce taxonomické zloženie.

Naprieč vzorkami bolo identifikované relatívne malé, ale konzistentné jadro taxónov prítomných vo všetkých vzorkách, sprevádzané veľkým počtom nízkofrekvenčných taxónov obmedzených na malý počet vzoriek. Tento vzor poukazuje na stabilnú kostru komunity s flexibilným periférnym zložením, typickú pre hostiteľsky asociované alebo environmentálne štruktúrované mikrobiálne komunity.

Najdominantnejším baktériovým taxónom zdieľaným medzi všetkými vzorkami bol rod *Malacoplasma*, ktorý prispieva k vyváženému črevnému ekosystému (napr. u lososa; [https://www.nature.com/articles/s41396-023-01379-z](https://www.nature.com/articles/s41396-023-01379-z)). Ďalšie dominantné baktérie, ako *Deefgea piscis*, môžu produkovať sekundárne metabolity prospešné pre zdravie rýb ([https://pubmed.ncbi.nlm.nih.gov/36048329/](https://pubmed.ncbi.nlm.nih.gov/36048329/)) alebo *Cetobacterium somerae*, ktoré zlepšujú črevné zdravie rýb prostredníctvom fermentačných produktov ([https://pubmed.ncbi.nlm.nih.gov/34780975/](https://pubmed.ncbi.nlm.nih.gov/34780975/)).

Celkovo tieto vzorky vykazujú charakteristiky zdravého črevného mikrobiómu rýb, keďže identifikované patogénne baktérie tvorili maximálne 2,7 % všetkých identifikovaných baktérií v jednotlivých vzorkách. Vzorka 25 vykazovala najvyššiu pozorovanú biodiverzitu, zatiaľ čo vzorky 10 a 23 najnižšiu. Nízka diverzita komunít dominovaných niekoľkými taxónmi bola indikovaná veľmi nízkymi hodnotami Shannonovho indexu (celková diverzita – bohatstvo + rovnomernosť), Pielouovho indexu (rovnomernosť) a Simpsonovho indexu (dominancia druhov, zvýrazňujúca hojné taxóny), ktoré boli vo vzorkách 10, 16, 22 a 4 všetky pod hodnotou 0,2. To môže naznačovať buď prirodzene nízku diverzitu v dôsledku environmentálnych faktorov (napr. strava – mäsožravce majú menej diverzný mikrobióm), alebo vplyv ošetrenia (napr. antibiotiká, keďže iba vo vzorke 4 boli patogény potvrdené na úrovni 0,12 % relatívnej abundancie). Naopak, vzorky 15 a 35 mali všetky tri indexy medzi najvyššími zo všetkých vzoriek, čo naznačuje vysoko diverznú komunitu s rovnomerne rozloženou abundanciou a môže poukazovať na zdravé ryby s pestrou stravou. Na NMDS a PCoA grafoch (Bray–Curtis vzdialenosť) bol identifikovaný určitý zhlukovací vzor, ktorý nie je spôsobený prítomnosťou známych patogénov, čo naznačuje úlohu ďalších faktorov.

---

## Návrhy pre budúce analýzy:

Na základe tohto full-length 16S datasetu zahŕňajú ďalšie analytické kroky s najvyššou komerčnou hodnotou vytvorenie referenčných (baseline) profilov črevného mikrobiómu a ponuku monitoringu na detekciu časových odchýlok spojených s manažmentom, stravou alebo environmentálnymi zmenami. Diverzitné metriky a výsledky skríningu patogénov môžu byť integrované do kompozitných indexov črevného zdravia a rizika, čo umožní intuitívne porovnávanie medzi vzorkami a časovými bodmi.

Maržu z rovnakého datasetu je možné zvýšiť pridaním funkčnej interpretácie bez potreby shotgun metagenomiky pomocou nástrojov Picrust2 alebo FAPROTAX, ktoré predikujú metabolické funkcie baktérií v mikrobiálnych komunitách. Pre hlbší vhľad do črevného mikrobiómu rýb a zdravia hostiteľa je možné využiť native RNA shotgun Nanopore sekvenovanie, ktoré umožňuje simultánne zachytiť transkriptómy mikróbov aj hostiteľa, a tým priamo hodnotiť aktívne metabolické dráhy, stresové a imunitné odpovede, interakcie hostiteľ–mikrób a funkčné zmeny, ktoré nemožno odvodiť iba z DNA-profilovania.

Pri viacvzorkových datasetoch (stovky vzoriek) je možné poskytovať klientom vyšší stupeň ekologického poznania o tom, ako mikrobiálne taxóny interagujú naprieč environmentálnymi gradientmi, aké vzory sa opakujú medzi habitatmi a čo to implikuje o funkčnej redundancii, adaptácii a zostavovaní komunít. Základné metabarcodingové výstupy je možné rozšíriť o analýzu mikrobiálnych sietí a interakcií, ako je to demonštrované v práci [https://www.nature.com/articles/s42003-024-06616-5](https://www.nature.com/articles/s42003-024-06616-5), kde bolo použité podmienené zhlukovanie spolu-výskytu na odhalenie opakujúcich sa ekologických modulov a funkčnej redundancie naprieč prostrediami. Rozšírenie detekcie patogénov o prahovo založené systémy včasného varovania a integrácia inferencie funkčných znakov môžu ďalej transformovať taxonomické dáta na biologicky a prakticky využiteľné poznatky.


Full-length 16S in gut microbiome provides higher taxonomic resolution (often to species; sometimes strains). Short regions (esp. V4) frequently collapse multiple species into one genus-level call, while full-length provides more informative sites across the gene and can separate closely related taxa better. This is a recurring conclusion across benchmarking studies. 

https://github.com/genomic-medicine-sweden/TRANA pipeline using Emu classifier vs https://epi2me.nanoporetech.com/epi2me-docs/workflows/wf-16s/ using minimap2:
The Emu classifier is specifically designed to generate accurate species-level abundance profiles from full-length 16S Nanopore reads by using an expectation–maximization (EM) algorithm to refine taxonomic assignments based on the collective evidence from all reads (https://pmc.ncbi.nlm.nih.gov/articles/PMC9939874/). In contrast to a simple alignment approach like minimap2, which only maps reads to reference sequences without resolving ambiguous matches, Emu iteratively adjusts the probability that each read arises from each candidate taxon, reducing false positives and improving abundance estimates. Benchmarking on simulated and mock communities shows that Emu produces lower relative abundance error and far fewer incorrect species calls than minimap2 alone, because it balances true positive detection with false positive suppression through its probabilistic model rather than relying solely on raw alignments.

The pipeline logic:

1. Check QC - FastQC, Nanoplot, MultiQC, Filtlong
2. EMU classifier with RiboGrove curated database
3. relative abundace tables
4. Krona - relative abundace results are displayed with Krona
5. pathogen detection via list comparison, see NEMESISdb below 
6. diversity indices and ordination plots, final tables (build Docker image)

I implemented a modified version of the TRANA pipeline https://github.com/luciazifcakova/TRANA_translate_modified for full-length Nanopore 16S rRNA data and extended it with custom post-processing and ecological analysis modules. In addition to taxonomic profiling using the EMU classifier with a curated RiboGrove database that contains full-length prokaryotic 16S rRNA sequences extracted from completely assembled genomes (https://www.sciencedirect.com/science/article/pii/S0923250822000171). I developed reproducible downstream workflows for quality control aggregation, abundance table generation, alpha and beta diversity analyses, ordination, clustering, pathogen-focused sub-analyses, and interactive visualization. The postprocessing workflow is containerized using Docker with pinned software versions and designed for scalable execution on HPC systems via Slurm, enabling reproducible, large-cohort microbiome analysis.

Pathogenic bacteria lists:

https://www.sciencedirect.com/science/article/pii/S235234092500856X
NEMESISdb is a set of three curated 16S rRNA full length sequence datasets enabling the identification and tracking of potentially pathogenic bacteria (PPB) across human, fish and crustacean hosts and helping reveal factors that influence their dynamics. A list of pathogenic bacteria for humans, fishes, and crustaceans from various studies and pathogen detection pipeline such as 16SPIP, FAPROTAX, MPD and MBPD. Full length 16S rRNA gene sequences of each of the pathogenic bacteria of the list was downloaded from the SILVA 138.2 SSU Ref NR99 bacterial database in order to obtain three pathogenic reference datasets for humans, fishes, and crustaceans, respectively. Lastly, each dataset was curated with homemade scripts to remove all sequences wrongly assigned at the species taxonomic level in SILVA 138.2 SSU Ref NR99.
https://doi.org/10.1016/j.resmic.2022.103936.

Validations and limitations:

While full-length 16S improves taxonomic resolution, relative abundance estimates remain influenced by PCR amplification bias, rRNA gene copy number variation, and database completeness. EMU reduces false positives compared to direct alignment (such as with minimap2), but cannot fully resolve taxa absent or misrepresented in reference databases. Consequently, abundance estimates are interpreted comparatively across samples rather than as absolute measures, and low-abundance taxa are preserved in downstream ecological analyses. Diversity metrics were computed on relative-abundance tables derived from EMU estimates; thus, interpretations focus on community structure and comparative trends rather than absolute microbial load.
31 samples had higher than 20% read duplication level that can either mean low biological diversity or techincal errors. However, duplication is expected in PCR amplified samples and FASTQC duplication metrics should be taken cautiously, as they are not designed for Nanopore data.

Results:

Community composition differed substantially among samples, with Bray–Curtis distances revealing clear clustering patterns. Ordination and hierarchical clustering consistently identified groups of samples with similar relative-abundance profiles. Presence–absence analysis using UpSet plots indicated the absence of a large universal core community, instead revealing a modular structure with taxa shared among subsets of samples. This suggests high community turnover and potential environmental or host-associated filtering shaping taxonomic composition. Across samples, we observed a relatively small but consistent core of taxa present in all samples, accompanied by a large number of low-frequency taxa that were restricted to few samples. This pattern indicates a stable community backbone with flexible peripheral membership, typical of host-associated or environmentally structured microbial communities.
Most dominat bacterium  that was shared among all samples was Malacoplasma, contributing to a balanced gut ecosystem (e.g. samolon - https://www.nature.com/articles/s41396-023-01379-z). Other dominant bactria, such as Deefgea piscis can produce secondary metabolites that benefit fish health (https://pubmed.ncbi.nlm.nih.gov/36048329/#:~:text=Strain%20D25T%20showed%20the,;%20Rhynchocypris%20kumgangensis;%20Tanakia%20koreensis.) or Cetobacterium somerae, that can improve gut health of fish with its fermaentation products (https://pubmed.ncbi.nlm.nih.gov/34780975/). Overall, these samples looks like heatlhy fish gut samples, as identified  pathogenic bacteria made up max. 2.7% ofidentified bacteria in the sample. Sample 25 had highest observed biodiversity, while sample 10 and 23 lowest. Less diverse community, dominated by few taxa was indicated by very low Shannon (overall diversity, richness + evenness), Pielou (evenness  - how equal abundances are) and Simpson index (dominance of species, weighted toward common species) were all below 0.2 in samples 10, 16, 22, 4. This can suggest either naturally low diversity becouse of envrionmental factor, such as diet (carnivora have less diverse microbiome) or treatment (e.g. antibiotics, as only in sample 4 pathogens were confirmed in 0.12% relative abundace). On the other hand, samples 15 and 35 had all three indices amongst highest from all samples, which can translates to highly diverse community that is distributed evenly, so it may suggest healthy fish with diverse diet. There is certain grouping patter recognized on NMDS and PCoA (Bray-Curtis distance) plots  that is not caused by presence of known pathogens, so other factor play a role. 


Suggestion for future analyses:

Building on this full-length 16S dataset, the next analytical steps with the greatest commercial value include establishing baseline gut microbiome profiles and offering monitoring to detect temporal deviations associated with management, diet, or environmental changes. Diversity metrics and pathogen screening results can be integrated into composite gut-health and risk indices, enabling intuitive benchmarking across samples and time points. 
It is possible to increase margin on the same dataset by adding functional interpretation without shotgun metagenomics by using Picrust2 or FAPROTAX that predicts the metabolic functions of bacteria in microbial communities. For further insights into fish gut microbiome and host health, native RNA shotgun Nanopore sequencing can be leveraged to capture both microbial and host transcriptomes simultaneously, enabling direct assessment of active metabolic pathways, stress and immune responses, host–microbe interactions, and functional shifts that cannot be inferred from DNA-based profiling alone.
With multi-sample datasets (hundreads of samples), we can provide client with higher-order ecological insight on how microbial taxa interact across environmental gradients, what patterns recur across habitats, and what that implies about functional redundancy, adaptation, and community assembly. We can extend basic metabarcoding outputs to microbial network and interaction analytics like in https://www.nature.com/articles/s42003-024-06616-5, where conditional co-occurrence clustering was applied to uncover recurring ecological modules and functional redundancy across environments. 
Expanding pathogen detection into threshold-based early-warning frameworks and incorporating functional trait inference can further translate taxonomic data into actionable biological insight. 

