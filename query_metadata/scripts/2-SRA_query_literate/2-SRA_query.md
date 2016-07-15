# Script: 2-SRA_query.R

- *Author: Scott Funkhouser*
- *Date: 20160707*
- *Project: [comparative-rna-editing](../../../README.md)*
- *Sub Folder: [query_metadata](../../query_metadata.md)*

## Table of Contents

1. [Objectives](#objectives)
2. [Install libraries](#install-libraries)
4. [Analysis](#analysis)
  - [Inspect tables and fields](#inspect-contents-of-sra-database)
  - [Search for ADAR-related data](#search-for-adar-related-data)
  - [Query data with SQL](#query-data-with-sql)
6. [Save data](#save-data)


```r
setwd("/mnt/research/ernstc_lab/comparative-rna-editing/query_metadata/scripts")
```

## Objectives

1. Use SRAdb package to query Sequence Read Archive data. The SRA should contain more raw
sequence files than GEO.

## Install libraries
Install and attach GEOmetadb


```r
# source("http://bioconductor.org/biocLite.R")
# biocLite("SRAdb")
library(SRAdb)
```

```
## Loading required package: RSQLite
```

```
## Loading required package: DBI
```

```
## Loading required package: methods
```

```
## Loading required package: graph
```

```
## Loading required package: RCurl
```

```
## Loading required package: bitops
```

```
## Setting options('download.file.method.GEOquery'='curl')
```

Download SRA metadata database


```r
if(!file.exists('../SRAmetadb.sqlite'))
    getSRAdbFile(destdir = "..", method = "wget")
```

## Analysis
Open connection


```r
con <- dbConnect(SQLite(),'../SRAmetadb.sqlite')
```

### Inspect contents of SRA database

1. Display tables
2. Isolate all fields across all tables
3. Find which 'key' fields are found across tables



```r
dbListTables(con)
```

```
##  [1] "col_desc"        "experiment"      "fastq"          
##  [4] "metaInfo"        "run"             "sample"         
##  [7] "sra"             "sra_ft"          "sra_ft_content" 
## [10] "sra_ft_segdir"   "sra_ft_segments" "study"          
## [13] "submission"
```

```r
field_list <- sapply(dbListTables(con), function(x) dbListFields(con, x))
str(field_list)
```

```
## List of 13
##  $ col_desc       : chr [1:7] "col_desc_ID" "table_name" "field_name" "type" ...
##  $ experiment     : chr [1:42] "experiment_ID" "bamFile" "fastqFTP" "experiment_alias" ...
##  $ fastq          : chr [1:7] "fastq_ID" "run_accession" "file_name" "md5" ...
##  $ metaInfo       : chr [1:2] "name" "value"
##  $ run            : chr [1:21] "run_ID" "bamFile" "run_alias" "run_accession" ...
##  $ sample         : chr [1:20] "sample_ID" "sample_alias" "sample_accession" "broker_name" ...
##  $ sra            : chr [1:75] "sra_ID" "SRR_bamFile" "SRX_bamFile" "SRX_fastqFTP" ...
##  $ sra_ft         : chr [1:74] "SRR_bamFile" "SRX_bamFile" "SRX_fastqFTP" "run_ID" ...
##  $ sra_ft_content : chr [1:75] "docid" "c0SRR_bamFile" "c1SRX_bamFile" "c2SRX_fastqFTP" ...
##  $ sra_ft_segdir  : chr [1:6] "level" "idx" "start_block" "leaves_end_block" ...
##  $ sra_ft_segments: chr [1:2] "blockid" "block"
##  $ study          : chr [1:21] "study_ID" "study_alias" "study_accession" "study_title" ...
##  $ submission     : chr [1:17] "submission_ID" "submission_alias" "submission_accession" "submission_comment" ...
```

```r
Reduce(intersect, field_list[c("sample", "study", "experiment")])
```

```
## [1] "broker_name"          "center_name"          "sra_link"            
## [4] "xref_link"            "ddbj_link"            "ena_link"            
## [7] "submission_accession" "sradb_updated"
```

The `submission_accession` looks like it can serve as a primary key. In fact
it corresponds to the "SRA number".
### Search for ADAR related data
SRAdb includes various search functions for searching key terms. Acquire
ADAR related results by searching 'ADAR'


```r
rna_editing <-
    getSRA(search_terms = "ADAR",
	         out_types = c('experiment','study', 'sample'), con)
dim(rna_editing)
```

```
## [1] 377  49
```

Display the titles of all ADAR related experiments


```r
knitr::kable(data.frame("ADAR_studies" = unique(rna_editing$study_title)))
```



|ADAR_studies                                                                                                                                                                                               |
|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|Evaluation of the mechanisms governing RNA-editing in a series of breast cancers equally distributed among the know molecular subtypes.                                                                    |
|Large-scale mRNA sequencing determines global regulation of RNA editing during brain development                                                                                                           |
|Genome-wide Identification of Human RNA Editing Sites by Parallel DNA Capturing and Sequencing                                                                                                             |
|Effects of ADARs on small RNA processing pathways in C. elegans                                                                                                                                            |
|Comprehensive analysis of RNA-Seq data reveals  extensive RNA editing in a human transcriptome                                                                                                             |
|Comprehensive identification of edited miRNAs in the human brain                                                                                                                                           |
|Accurate Identification of A-to-I RNA editing in human by transcriptome sequencing                                                                                                                         |
|Caenorhabditis elegans strain:N2, adr-1, adr-2, adr-1;adr-2 Transcriptome or Gene expression                                                                                                               |
|Nascent-seq indicates widespread cotranscriptional RNA editing in Drosophila                                                                                                                               |
|Study functions of ADAR proteins using next generation sequencing of genome and transcriptome                                                                                                              |
|Mus musculus strain:C57/Bl6 Variation                                                                                                                                                                      |
|Global regulation of alternative splicing by adenosine deaminase acting on RNA (ADAR) [RNA-seq]                                                                                                            |
|Genome-Wide Analysis of A-to-I RNA Editing via Single Molecule Sequencing in Drosophila                                                                                                                    |
|Profiling of RNA editing in Caenorhabditis elegans                                                                                                                                                         |
|Analysis of pre-mRNA splicing trans-regulation in human lymphoblastoid cell lines                                                                                                                          |
|Systematic Mapping of ADAR1 Binding Reveals its Regulatory Roles in Multiple RNA Processing Pathways [small RNA-seq]                                                                                       |
|RNA Sequencing Quantitative Analysis and identification of RNA editing sites of Wild Type and ADAR1 editing deficient (ADAR1E861A) murine fetal liver RNA                                                  |
|Xenopus laevis Transcriptome or Gene expression                                                                                                                                                            |
|ADAR2 reproducibly changes abundance and sequence of mature microRNAs in the mouse brain [RNA-Seq]                                                                                                         |
|A comprehensive catalog of the C. elegans dsRNAome                                                                                                                                                         |
|Macaca mulatta Transcriptome or Gene expression                                                                                                                                                            |
|The RNA editing enzyme ADAR1 is a key regulatory of innate immune responses to RNA                                                                                                                         |
|Cis regulatory effects on A-to-I RNA editing in Drosophila melanogaster, Drosophila sechellia and their F1 hybrids                                                                                         |
|Widespread RNA Binding by Chromatin Associated Proteins                                                                                                                                                    |
|New non-coding lytic transcripts derived from the Epstein Barr virus latency origin of replication oriP are hyper-edited, bind the paraspeckle protein, NONO/p54nrb, and support lytic viral transcription |
|Small RNA in wild type Caenorhabditis elegans and ADAR mutants                                                                                                                                             |
|Mus musculus raw sequence reads                                                                                                                                                                            |
|Identification of the long, edited dsRNAome in LPS-stimulated bone marrow-derived macrophages (BMDMs)                                                                                                      |
|TRIBE : Hijacking an RNA-editing enzyme to identify cell-specific targets of RNA-binding proteins                                                                                                          |
|Homo sapiens Raw sequence reads                                                                                                                                                                            |

### Query data with SQL

> The main goal of this script is to design a SQL query that can *unearth*
> sequencing data that may or may not have been originally intended for
> RNA-editing research

Steps to find usable data, regardless if what kind of study it came from:

1. Find samples that have the same sample.sample_accession...
2. That have at least one WGS and one RNA-Seq experiment associated with them



```r
query <- dbGetQuery(con,
                    paste(
                          "SELECT
                            sample.sample_accession,
                            sample.scientific_name,
                            sample.sample_alias,
                            sample.center_name,
                            sample.description,
                            experiment.library_strategy
                          FROM sample
                          JOIN experiment ON
                            sample.sample_accession = experiment.sample_accession
                          WHERE experiment.library_strategy in ('WGS','RNA-Seq')
                          GROUP by sample.sample_accession
                          HAVING COUNT(DISTINCT experiment.library_strategy) = 2"
                        )
                    )
```

Check how many usable samples of each species there are.


```r
knitr::kable(data.frame("Usable_samples_for_each_species" = sort(table(query$scientific_name),
                                                                 decreasing = TRUE)))
```



|                                                 | Usable_samples_for_each_species|
|:------------------------------------------------|-------------------------------:|
|Homo sapiens                                     |                             181|
|Capsella grandiflora                             |                             149|
|unclassified sequences                           |                              53|
|marine metagenome                                |                              49|
|human gut metagenome                             |                              34|
|unclassified Bacteria (miscellaneous)            |                              30|
|Diospyros lotus                                  |                              18|
|Drosophila yakuba                                |                              15|
|Glycine soja                                     |                               8|
|Sus scrofa                                       |                               8|
|Streptococcus pyogenes                           |                               7|
|groundwater metagenome                           |                               6|
|Hevea brasiliensis                               |                               6|
|Caenorhabditis elegans                           |                               5|
|Macaca mulatta                                   |                               5|
|Pan troglodytes                                  |                               5|
|Pongo abelii                                     |                               5|
|wastewater metagenome                            |                               5|
|Bursaphelenchus xylophilus                       |                               4|
|Mus musculus                                     |                               4|
|Mycobacterium tuberculosis                       |                               4|
|plant metagenome                                 |                               4|
|Plasmodium falciparum                            |                               4|
|Pseudomonas fluorescens                          |                               4|
|Trichinella pseudospiralis                       |                               4|
|activated sludge metagenome                      |                               3|
|Oryza sativa                                     |                               3|
|Saccharomyces cerevisiae                         |                               3|
|Thermoanaerobacter sp. X514                      |                               3|
|Beta vulgaris subsp. vulgaris                    |                               2|
|Canis lupus familiaris                           |                               2|
|Drosophila melanogaster                          |                               2|
|Eichhornia crassipes                             |                               2|
|Enterobacter cloacae                             |                               2|
|Falco                                            |                               2|
|gut metagenome                                   |                               2|
|Helicobacter pylori                              |                               2|
|Oreochromis niloticus                            |                               2|
|Paramecium tetraurelia                           |                               2|
|Trichuris suis                                   |                               2|
|Verticillium nonalfalfae                         |                               2|
|Agkistrodon contortrix                           |                               1|
|Aiptasia CC7                                     |                               1|
|Ambrosiozyma kashinagacola                       |                               1|
|Amoebophrya sp. ex Karlodinium veneficum         |                               1|
|Anopheles atroparvus                             |                               1|
|Anopheles funestus                               |                               1|
|Anopheles minimus                                |                               1|
|Auxenochlorella protothecoides sp 0710           |                               1|
|Azadirachta indica                               |                               1|
|Bacillus anthracis str. SVA11                    |                               1|
|Caenorhabditis afra                              |                               1|
|Caenorhabditis castelli                          |                               1|
|Caenorhabditis doughertyi                        |                               1|
|Caenorhabditis guadeloupensis                    |                               1|
|Caenorhabditis macrosperma                       |                               1|
|Caenorhabditis nouraguensis                      |                               1|
|Caenorhabditis plicata                           |                               1|
|Caenorhabditis sp. 16 KK-2011                    |                               1|
|Caenorhabditis sp. 1 KK-2011                     |                               1|
|Caenorhabditis sp. 21 LS-2015                    |                               1|
|Caenorhabditis sp. 26 LS-2015                    |                               1|
|Caenorhabditis sp. 31 LS-2015                    |                               1|
|Caenorhabditis sp. 32 LS-2015                    |                               1|
|Caenorhabditis sp. 38 MB-2015                    |                               1|
|Caenorhabditis sp. 39 LS-2015                    |                               1|
|Caenorhabditis sp. 40 LS-2015                    |                               1|
|Caenorhabditis sp. 43 LS-2015                    |                               1|
|Campylobacter jejuni subsp. jejuni NCTC 11168-PO |                               1|
|Candida albicans 19F                             |                               1|
|Candida albicans L26                             |                               1|
|Candida albicans P34048                          |                               1|
|Candida albicans P37005                          |                               1|
|Candida albicans P37037                          |                               1|
|Candida albicans P57055                          |                               1|
|Candida albicans P60002                          |                               1|
|Candida albicans P75016                          |                               1|
|Candida albicans P75063                          |                               1|
|Candida albicans P76055                          |                               1|
|Candida albicans P76067                          |                               1|
|Candida albicans P78042                          |                               1|
|Candida albicans P78048                          |                               1|
|Candida albicans P94015                          |                               1|
|Candida sp. JCM 15000                            |                               1|
|Candidatus Accumulibacter phosphatis             |                               1|
|Cardiocondyla obscurior                          |                               1|
|catfish                                          |                               1|
|Ceraceosorus bombacis                            |                               1|
|Chlorocebus sabaeus                              |                               1|
|Chromera velia CCMP2878                          |                               1|
|Chrysochromulina sp. CCMP291                     |                               1|
|Cimex lectularius                                |                               1|
|Drechmeria coniospora                            |                               1|
|Drosophila simulans                              |                               1|
|Enoplus brevis                                   |                               1|
|Escherichia coli                                 |                               1|
|Exaiptasia pallida                               |                               1|
|Fagopyrum esculentum                             |                               1|
|Folsomia candida                                 |                               1|
|Fraxinus excelsior                               |                               1|
|freshwater metagenome                            |                               1|
|Ganoderma lucidum G.260125-1                     |                               1|
|Gerris buenoi                                    |                               1|
|Helicobacter pylori J99                          |                               1|
|Heliconius melpomene rosina                      |                               1|
|Helicosporidium sp. ATCC 50920                   |                               1|
|Hyla arborea                                     |                               1|
|Klebsiella pneumoniae 120_1020                   |                               1|
|Klebsiella pneumoniae 140_1040                   |                               1|
|Klebsiella pneumoniae 160_1080                   |                               1|
|Klebsiella pneumoniae 280_1220                   |                               1|
|Klebsiella pneumoniae 361_1301                   |                               1|
|Klebsiella pneumoniae 440_1540                   |                               1|
|Klebsiella pneumoniae 500_1420                   |                               1|
|Klebsiella pneumoniae 540_1460                   |                               1|
|Klebsiella pneumoniae 646_1568                   |                               1|
|Klebsiella pneumoniae DMC0526                    |                               1|
|Klebsiella pneumoniae DMC0799                    |                               1|
|Klebsiella pneumoniae DMC1097                    |                               1|
|Klebsiella pneumoniae DMC1316                    |                               1|
|Klebsiella pneumoniae KP-11                      |                               1|
|Klebsiella pneumoniae KP-7                       |                               1|
|Klebsiella pneumoniae UHKPC01                    |                               1|
|Klebsiella pneumoniae UHKPC02                    |                               1|
|Klebsiella pneumoniae UHKPC04                    |                               1|
|Klebsiella pneumoniae UHKPC05                    |                               1|
|Klebsiella pneumoniae UHKPC06                    |                               1|
|Klebsiella pneumoniae UHKPC07                    |                               1|
|Klebsiella pneumoniae UHKPC09                    |                               1|
|Klebsiella pneumoniae UHKPC17                    |                               1|
|Klebsiella pneumoniae UHKPC179                   |                               1|
|Klebsiella pneumoniae UHKPC18                    |                               1|
|Klebsiella pneumoniae UHKPC22                    |                               1|
|Klebsiella pneumoniae UHKPC23                    |                               1|
|Klebsiella pneumoniae UHKPC24                    |                               1|
|Klebsiella pneumoniae UHKPC26                    |                               1|
|Klebsiella pneumoniae UHKPC27                    |                               1|
|Klebsiella pneumoniae UHKPC28                    |                               1|
|Klebsiella pneumoniae UHKPC29                    |                               1|
|Klebsiella pneumoniae UHKPC31                    |                               1|
|Klebsiella pneumoniae UHKPC32                    |                               1|
|Klebsiella pneumoniae UHKPC33                    |                               1|
|Klebsiella pneumoniae UHKPC40                    |                               1|
|Klebsiella pneumoniae UHKPC45                    |                               1|
|Klebsiella pneumoniae UHKPC47                    |                               1|
|Klebsiella pneumoniae UHKPC48                    |                               1|
|Klebsiella pneumoniae UHKPC 52                   |                               1|
|Klebsiella pneumoniae UHKPC57                    |                               1|
|Klebsiella pneumoniae UHKPC59                    |                               1|
|Klebsiella pneumoniae UHKPC61                    |                               1|
|Klebsiella pneumoniae UHKPC67                    |                               1|
|Klebsiella pneumoniae UHKPC69                    |                               1|
|Klebsiella pneumoniae UHKPC77                    |                               1|
|Klebsiella pneumoniae UHKPC81                    |                               1|
|Klebsiella pneumoniae UHKPC96                    |                               1|
|Klebsiella pneumoniae VAKPC252                   |                               1|
|Klebsiella pneumoniae VAKPC254                   |                               1|
|Klebsiella pneumoniae VAKPC269                   |                               1|
|Klebsiella pneumoniae VAKPC270                   |                               1|
|Klebsiella pneumoniae VAKPC276                   |                               1|
|Klebsiella pneumoniae VAKPC278                   |                               1|
|Klebsiella pneumoniae VAKPC280                   |                               1|
|Klebsiella pneumoniae VAKPC297                   |                               1|
|Klebsiella pneumoniae VAKPC309                   |                               1|
|Leptomonas pyrrhocoris                           |                               1|
|Leptomonas seymouri                              |                               1|
|Lytechinus variegatus                            |                               1|
|Macrostomum lignano                              |                               1|
|Magnaporthiopsis incrustans                      |                               1|
|Magnaporthiopsis rhizophila                      |                               1|
|Malus fusca                                      |                               1|
|marine sediment metagenome                       |                               1|
|Microplitis bicoloratus                          |                               1|
|Monocercomonoides sp. PA203                      |                               1|
|Myroides odoratimimus                            |                               1|
|Naegleria fowleri                                |                               1|
|Nakataea oryzae                                  |                               1|
|Ocimum tenuiflorum                               |                               1|
|Ogataea methanolica                              |                               1|
|Olea europaea subsp. europaea                    |                               1|
|Onthophagus taurus                               |                               1|
|Ophioceras dolichostomum                         |                               1|
|Oropetium thomaeum                               |                               1|
|Oryctes borbonicus                               |                               1|
|Oryza brachyantha                                |                               1|
|Oryza sativa Indica Group                        |                               1|
|Paulinella chromatophora                         |                               1|
|Picea glauca                                     |                               1|
|Poa pratensis                                    |                               1|
|Primula veris                                    |                               1|
|Pristionchus pacificus                           |                               1|
|Pseudogymnoascus sp. 03VT05                      |                               1|
|Pseudogymnoascus sp. 05NY08                      |                               1|
|Pseudogymnoascus sp. 23342-1-I1                  |                               1|
|Pseudogymnoascus sp. 24MN13                      |                               1|
|Pseudogymnoascus sp. WSF 3629                    |                               1|
|Pseudogymnoascus verrucosus                      |                               1|
|Pseudohalonectria lignicola                      |                               1|
|Pseudomonas syringae pv. syringae str. B301D-R   |                               1|
|Pseudozyma aphidis                               |                               1|
|Puccinia striiformis f. sp. tritici              |                               1|
|Pyropia yezoensis                                |                               1|
|Python molurus                                   |                               1|
|Rhodosporidium toruloides NP11                   |                               1|
|Ruminiclostridium thermocellum ATCC 27405        |                               1|
|Salmonella enterica                              |                               1|
|Salvia miltiorrhiza                              |                               1|
|Sarcocystis neurona                              |                               1|
|Schmidtea mediterranea                           |                               1|
|sediment metagenome                              |                               1|
|Sigmodon hispidus                                |                               1|
|soil metagenome                                  |                               1|
|Solanum americanum                               |                               1|
|Spironucleus salmonicida                         |                               1|
|Staphylococcus aureus subsp. aureus NCTC 8325    |                               1|
|Streptococcus suis                               |                               1|
|Streptomyces sp. DpondAA-B6                      |                               1|
|Streptomyces sp. FR-008                          |                               1|
|Taiwanofungus camphoratus                        |                               1|
|Talaromyces marneffei PM1                        |                               1|
|Talaromyces purpureogenus                        |                               1|
|Termitomyces sp. J132                            |                               1|
|Toxocara canis                                   |                               1|
|Toxoplasma gondii ME49                           |                               1|
|Trichinella britovi                              |                               1|
|Trichinella murrelli                             |                               1|
|Trichinella nativa                               |                               1|
|Trichinella nelsoni                              |                               1|
|Trichinella papuae                               |                               1|
|Trichinella patagoniensis                        |                               1|
|Trichinella spiralis                             |                               1|
|Trichinella sp. T6                               |                               1|
|Trichinella sp. T8                               |                               1|
|Trichinella sp. T9                               |                               1|
|Trichinella zimbabwensis                         |                               1|
|unidentified                                     |                               1|
|Vaccinium macrocarpon                            |                               1|
|Verticillium dahliae                             |                               1|
|Xanthophyllomyces dendrorhous                    |                               1|
|Yarrowia sp. JCM 30694                           |                               1|
|Yarrowia sp. JCM 30695                           |                               1|
|Zoysia japonica                                  |                               1|
|Zymoseptoria tritici                             |                               1|

For species of interest (mammalian species where at least 2 samples each with WGS
and RNA-Seq data exist), assemble all experiments for each sample.

1. Isolate candidate samples from each species
2. Re-query experiments table using isolated samples and store in a list



```r
species_oi <- c("Homo sapiens",
                "Sus scrofa",
                "Macaca mulatta",
                "Pan troglodytes",
                "Pongo abelii",
                "Mus musculus",
                "Canis lupus familiaris")
```

Initialize master list that will contain all experimental data for all candidate
samples for each species


```r
species_list <- list()
for (i in 1:length(species_oi)) {

    # Subset samples for species of interest
    idx <- query$scientific_name == species_oi[i]
    idx <- replace(idx, is.na(idx), FALSE)
    samples <- query[idx, 1]

    # Initialize empty list for species
    ls <- list()

    # For each sample, append each `experiment` to the list
    for (j in 1:length(samples)) {
        exp <- dbGetQuery(con,
                          paste0(
                                 "SELECT *
                                  FROM experiment
                                  WHERE sample_accession = ", "'",samples[j],"'"))
        ls[[j]] <- exp
    }

    # Store results in master list
    species_list[[i]] <- ls
}
```

## Save data


```r
save(query, rna_editing, species_list, file = "../2-SRA_query.RData")
```

