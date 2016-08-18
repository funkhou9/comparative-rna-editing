# comparative-rna-editing

> What patterns in RNA edited sites (positioning in the transcriptome, editing levels) can be
> discovered by analyzing data from different mammalian species harboring distinct SINE elements?
> Very little work has been done to apply comparative genomics to this phenomenon
> using both WGS and RNA-Seq from the same individuals/samples.

## Possible sources of data from literature

### Mouse

- [Huntley et al - 1 mouse](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4714477/)
	* [RNASeq - 9 tissues](http://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE74747)
	* [WGS](http://www.ebi.ac.uk/ena/data/view/ERP010840)

## Analysis scripts

[**query_metadata**](./query_metadata/query_metadata.md): Scripts using Bioconductor packages
designed to query data from NCBI databases. Ideally, I can recover the required data I need (WGS
and RNAseq from the same individuals) from experiments not necessarily originally intended to
investigate RNA editing. This may prove difficult since repositories such as the
sequence read archive generally don't have personally identifiable data.

> Click [here](https://twitter.com/saf6/status/760977581302804480) for a twitter
> discussion of this topic. Repositories such as GTEx and ICGC may be used,
> but they are human-only and require an application to access raw sequencing
> data. Nevertheless, they may prove useful for human although the primate component
> of this study can come from non-human primate data as well.
