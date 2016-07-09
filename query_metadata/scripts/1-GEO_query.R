#' # Script: 1-GEO_query.R
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
#' 6. [Save data](#save-data)

setwd("/mnt/research/ernstc_lab/comparative-rna-editing/query_metadata/scripts")

#' ## Objectives
#' 
#' 1. Use GEOmetadb to query experiments that may have valuable data for use in a comparative RNA
#' editing study
#' 
#' ## Install libraries
# library(devtools)
# library(magrittr)

#' Install and attach GEOmetadb
source("http://bioconductor.org/biocLite.R")
biocLite("GEOmetadb")
library(GEOmetadb)

#' Download GEOmetadb database
if(!file.exists('../GEOmetadb.sqlite')) getSQLiteFile(destdir = "../")

#' ## Analysis
#' Open connection
con <- dbConnect(SQLite(),'GEOmetadb.sqlite')

#' Inspect GEO database
dbListTables(con)

#' Inspect columns in GSO Series and Samples data
dbListFields(con, 'gse')
dbListFields(con, 'gsm')

#' ### Query data with SQL
#' 
#' Example SQL code to query, join tables, subset, etc.
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
#' Save series (experiments) that emphasize both expression profiling and genome variation profiling 
#' by way of high throughput sequencing
candidates <-
  dbGetQuery(con,
             paste(
               "SELECT * FROM gse
                WHERE type LIKE '%Expression profiling by high throughput sequencing%'
                AND type LIKE '%Genome variation profiling by high throughput sequencing%'"
            ))


#' Inspect experiment titles
candidates$title

#' Retreive GSEs from intriguing titles - titles that may involve mammalian species of interest
gse <- candidates$gse[c(4, 7, 8, 11, 12, 16, 19)]
gse

#' Retreive sample information from chosen series
candidate_samples <- 
  dbGetQuery(con,
             paste(
               "SELECT * FROM gsm
                WHERE series_id='GSE29184'
                OR series_id='GSE38685'
                OR series_id='GSE41729'
                OR series_id='GSE62952'
                OR series_id='GSE63420'
                OR series_id='GSE68559'
                OR series_id='GSE75935'"
            ))


#' ## Save data

