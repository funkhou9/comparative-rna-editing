#' # Script: 2-SRA_query.R
#'
#' - *Author: Scott Funkhouser*
#' - *Date: 20160707*
#' - *Project: [comparative-rna-editing](../../../README.md)*
#' - *Sub Folder: [query_metadata](../../query_metadata.md)*
#'
#' ## Table of Contents
#'
#' 1. [Objectives](#objectives)
#' 2. [Install libraries](#install-libraries)
#' 4. [Analysis](#analysis)
#'   - [Inspect tables and fields](#inspect-contents-of-sra-database)
#' 6. [Save data](#save-data)

setwd("/mnt/research/ernstc_lab/comparative-rna-editing/query_metadata/scripts")

#' ## Objectives
#'
#' 1. Use SRAdb package to query Sequence Read Archive data. The SRA should contain more raw
#' sequence files than GEO.
#'
#' ## Install libraries
# library(devtools)
# library(magrittr)

#' Install and attach GEOmetadb
# source("http://bioconductor.org/biocLite.R")
# biocLite("SRAdb")
library(SRAdb)

#' Download SRA metadata database
if(!file.exists('../SRAmetadb.sqlite'))
    getSRAdbFile(destdir = "..", method = "wget")

#' ## Analysis
#' Open connection
con <- dbConnect(SQLite(),'../SRAmetadb.sqlite')

#' ### Inspect contents of SRA database
#'
#' 1. Display tables
#' 2. Isolate all fields across all tables
#' 3. Find which 'key' fields are found across tables
#'
dbListTables(con)
field_list <- sapply(dbListTables(con), function(x) dbListFields(con, x))
str(field_list)
Reduce(intersect, field_list[c("sample", "study", "experiment")])

#' The `submission_accession` looks like it can serve as a primary key. In fact
#' it corresponds to the "SRA number".

#' Acquire results by searching ADAR specific terms with built-in search function
rna_editing <-
    getSRA(search_terms = "ADAR",
	       out_types = c('run','study'), con)
dim(rna_editing)
unique(rna_editing$study_title)

#' ### Query data with SQL
#'
#' *Example SQL code to query, join tables, subset, etc.*
#'
#' > SELECT
#' >   albums.name,
#' >   albums.year,
#' >   artists.name AS 'Artist'
#' > FROM
#' >   albums
#' > JOIN artists ON
#' >   albums.artist_id = artists.id
#' > WHERE
#' >   albums.year > 1980;
#'
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

#' ## Save data
save(query, rna_editing, file = "../2-SRA_query.RData")
