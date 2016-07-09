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
6. [Save data](#save-data)


```r
setwd("/mnt/research/ernstc_lab/comparative-rna-editing/query_metadata/scripts")
```

## Objectives

1. Use SRAdb package to query Sequence Read Archive data. The SRA should contain more raw
sequence files than GEO.

## Install libraries


```r
# library(devtools)
# library(magrittr)
```

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
Acquire results by searching ADAR specific terms with built-in search function


```r
rna_editing <-
    getSRA(search_terms = "ADAR",
	       out_types = c('run','study'), con)
dim(rna_editing)
```

```
## [1] 470  23
```

```r
unique(rna_editing$study_title)
```

```
##  [1] "Evaluation of the mechanisms governing RNA-editing in a series of breast cancers equally distributed among the know molecular subtypes."                                                                   
##  [2] "Large-scale mRNA sequencing determines global regulation of RNA editing during brain development"                                                                                                          
##  [3] "Genome-wide Identification of Human RNA Editing Sites by Parallel DNA Capturing and Sequencing"                                                                                                            
##  [4] "Effects of ADARs on small RNA processing pathways in C. elegans"                                                                                                                                           
##  [5] "Comprehensive analysis of RNA-Seq data reveals  extensive RNA editing in a human transcriptome"                                                                                                            
##  [6] "Comprehensive identification of edited miRNAs in the human brain"                                                                                                                                          
##  [7] "Accurate Identification of A-to-I RNA editing in human by transcriptome sequencing"                                                                                                                        
##  [8] "Caenorhabditis elegans strain:N2, adr-1, adr-2, adr-1;adr-2 Transcriptome or Gene expression"                                                                                                              
##  [9] "Nascent-seq indicates widespread cotranscriptional RNA editing in Drosophila"                                                                                                                              
## [10] "Study functions of ADAR proteins using next generation sequencing of genome and transcriptome"                                                                                                             
## [11] "Mus musculus strain:C57/Bl6 Variation"                                                                                                                                                                     
## [12] "Global regulation of alternative splicing by adenosine deaminase acting on RNA (ADAR) [RNA-seq]"                                                                                                           
## [13] "Genome-Wide Analysis of A-to-I RNA Editing via Single Molecule Sequencing in Drosophila"                                                                                                                   
## [14] "Profiling of RNA editing in Caenorhabditis elegans"                                                                                                                                                        
## [15] "Analysis of pre-mRNA splicing trans-regulation in human lymphoblastoid cell lines"                                                                                                                         
## [16] "Systematic Mapping of ADAR1 Binding Reveals its Regulatory Roles in Multiple RNA Processing Pathways [small RNA-seq]"                                                                                      
## [17] "RNA Sequencing Quantitative Analysis and identification of RNA editing sites of Wild Type and ADAR1 editing deficient (ADAR1E861A) murine fetal liver RNA"                                                 
## [18] "Xenopus laevis Transcriptome or Gene expression"                                                                                                                                                           
## [19] "ADAR2 reproducibly changes abundance and sequence of mature microRNAs in the mouse brain [RNA-Seq]"                                                                                                        
## [20] "A comprehensive catalog of the C. elegans dsRNAome"                                                                                                                                                        
## [21] "Macaca mulatta Transcriptome or Gene expression"                                                                                                                                                           
## [22] "The RNA editing enzyme ADAR1 is a key regulatory of innate immune responses to RNA"                                                                                                                        
## [23] "Cis regulatory effects on A-to-I RNA editing in Drosophila melanogaster, Drosophila sechellia and their F1 hybrids"                                                                                        
## [24] "Widespread RNA Binding by Chromatin Associated Proteins"                                                                                                                                                   
## [25] "New non-coding lytic transcripts derived from the Epstein Barr virus latency origin of replication oriP are hyper-edited, bind the paraspeckle protein, NONO/p54nrb, and support lytic viral transcription"
## [26] "Small RNA in wild type Caenorhabditis elegans and ADAR mutants"                                                                                                                                            
## [27] "Mus musculus raw sequence reads"                                                                                                                                                                           
## [28] "Identification of the long, edited dsRNAome in LPS-stimulated bone marrow-derived macrophages (BMDMs)"                                                                                                     
## [29] "TRIBE : Hijacking an RNA-editing enzyme to identify cell-specific targets of RNA-binding proteins"                                                                                                         
## [30] "Homo sapiens Raw sequence reads"
```

### Query data with SQL

*Example SQL code to query, join tables, subset, etc.*

> SELECT
>   albums.name,
>   albums.year,
>   artists.name AS 'Artist'
> FROM
>   albums
> JOIN artists ON
>   albums.artist_id = artists.id
> WHERE
>   albums.year > 1980;



```r
query <- dbGetQuery(con,
           paste(
           	   "SELECT
                  sample.scientific_name,
                  sample.sample_accession,
                  sample.submission_accession,
                  experiment.library_strategy
                FROM sample
                JOIN experiment ON
                  sample.sample_accession = experiment.sample_accession
                WHERE
                  sample.scientific_name = 'Homo sapiens'
                AND
                  experiment.library_strategy = 'WGS'
                OR
                  sample.scientific_name = 'Homo sapiens'
                AND
                  experiment.library_strategy = 'RNA-Seq'"))
```

## Save data


```r
save(query, rna_editing, file = "../2-SRA_query.RData")
```

