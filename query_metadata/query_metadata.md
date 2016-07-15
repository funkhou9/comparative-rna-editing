[back](../README.md)

# Query_metadata

> Scripts using Bioconductor packages designed to query data from NCBI databases. Ideally, I can
> recover the required data I need (WGS and RNAseq from the same individuals) from experiments not
> necessarily originally intended to investigate RNA editing.

[**1-GEO_query.R**](./scripts/1-GEO_query_literate/1-GEO_query.md) Using the GEOmetadb package to query data
that may have investigated both genome variation and gene expression using high-throughput sequencing
data.

[**2-SRA_query.R**](./scripts/2-SRA_query_literate/2-SRA_query.md) A similar query using the SRAdb package.
The Sequence Read Archive is more likely to possess raw sequencing data (fastq files) necessary for
[my pipeline](https://github.com/funkhou9/variant_calling_pipeline)
