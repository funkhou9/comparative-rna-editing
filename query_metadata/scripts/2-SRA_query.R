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
#'   - [Search for ADAR-related data](#search-for-adar-related-data)
#'   - [Query data with SQL](#query-data-with-sql)
#' 6. [Save data](#save-data)

setwd("/mnt/research/ernstc_lab/comparative-rna-editing/query_metadata/scripts")

#' ## Objectives
#'
#' 1. Use SRAdb package to query Sequence Read Archive data. The SRA should contain more raw
#' sequence files than GEO.
#'
#' ## Install libraries

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

#' ### Search for ADAR related data

#' SRAdb includes various search functions for searching key terms. Acquire
#' ADAR related results by searching 'ADAR'
rna_editing <-
    getSRA(search_terms = "ADAR",
	         out_types = c('experiment','study', 'sample'), con)
dim(rna_editing)

#' Display the titles of all ADAR related experiments
knitr::kable(data.frame("ADAR_studies" = unique(rna_editing$study_title)))

#' ### Query data with SQL
#'
#' > The main goal of this script is to design a SQL query that can *unearth*
#' > sequencing data that may or may not have been originally intended for
#' > RNA-editing research
#'
#' Steps to find usable data, regardless if what kind of study it came from:
#'
#' 1. Find samples that have the same sample.sample_accession...
#' 2. That have at least one WGS and one RNA-Seq experiment associated with them
#'

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

#' Check how many usable samples of each species there are.
knitr::kable(data.frame("Usable_samples_for_each_species" = sort(table(query$scientific_name),
                                                                 decreasing = TRUE)))

#' For species of interest (mammalian species where at least 2 samples each with WGS
#' and RNA-Seq data exist), assemble all experiments for each sample.
#'
#' 1. Isolate candidate samples from each species
#' 2. Re-query experiments table using isolated samples and store in a list
#'

species_oi <- c("Homo sapiens",
                "Sus scrofa",
                "Macaca mulatta",
                "Pan troglodytes",
                "Pongo abelii",
                "Mus musculus",
                "Canis lupus familiaris")

#' Initialize master list that will contain all experimental data for all candidate
#' samples for each species
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


#' ## Save data
save(query, rna_editing, species_list, file = "../2-SRA_query.RData")
