# DRAM2
## Welcome to the wiki for Distilling and Refining Annotations of Metabolism 2 (DRAM2)!

## **As of May 11, 2026, we will not be making public changes to DRAM2 code ahead of our upcoming publication. We appreciate your patience & stay tuned!**

### Introduction

DRAM2 (Distilling and Refining Annotations of Metabolism, version 2) is a tool for annotating genomic and metagenomic assemblies (e.g., scaffolds or contigs) as well as predicted genes (nucleotide or amino acid sequences). It organizes genome annotations into metabolic functions across three levels of increasing interpretation: (1) **ANNOTATE**, (2) **SUMMARIZE**, and (3) **VISUALIZE**. The **ANNOTATE** output contains all database hits for every gene in each genome, generating a comprehensive output of most annotation pipelines. DRAM2 extends beyond this by organizing (**SUMMARIZE**) and visualizing (**VISUALIZE**) annotations into ecosystem-relevant functional categories, enabling more interpretable comparisons across genomes and ecosystems. The DRAM2 workflow enables the analysis of large numbers of microbial genomes or metagenomes, highlighting functional guilds and supporting inference of organismal metabolism across datasets.

### DRAM2 Overview

> _Here provide we an overview on the DRAM2 workflow
A quick start guide can be found here https://dramit.readthedocs.io/en/latest/usage.html 
A complete list of pipeline configuration parameters can be found here: [Parameters API](https://dramit.readthedocs.io/en/latest/params_doc.html)

### DRAM2 workflow

1) Gene calling
2) Gene annotation
3) Summarize gene annotations based on curated datasets to ascribe function to MAGs
4) Generate an interactive heatmap of ecosystem-relevant MAG level metabolic function

#### 1) Gene calling

DRAM2 uses Prodigal to find open reading frames (ORFs) from genomes, Metagenome Assembled Genomes, (MAGs), or assemblies for downstream annotation. Alternatively, users can supply genes called using another platform. 

#### 2) Gene annotation

After gene-calling in Prodigal, DRAM2 annotates genes in each genome (or Metagenome Assembled Genome (MAG)) using a suite of user-defined databases, including [KEGG](https://www.kegg.jp/) (if provided by the user), [UniRef90](https://www.uniprot.org/), [PFAM](https://pfam.xfam.org/), [dbCAN3](http://bcb.unl.edu/dbCAN2/), [RefSeq Viral](https://www.ncbi.nlm.nih.gov/genome/viruses/), [VOGDB](http://vogdb.org/), [MEROPS](https://www.ebi.ac.uk/merops/), and optional user-defined databases. A full list of available annotation databases can be found here: [WrightonLabCSU/dram pipeline parameters](https://dramit.readthedocs.io/en/latest/params_doc.html#pipeline-steps). ANNOTATE then integrates results across all databases, increasing annotation coverage and yielding ~25% more database hits than commonly used annotators such as DFAST, MetaERG, and Prokka. The output of this step (“raw-annotations.tsv”) contains all database annotations. DRAM2 also generates ANNOTATE folder containing: (1) the annotated nucleotide and amino acid fasta files of all genes, (2) genome quality data generated via QUAST, (3) .gff files for each genome, and (4) database-specific files produced during the gene annotation process (i.e. HMMsearch output, MMseq2s output, dbcan3-hmm and dbcan3SUB-hmm etc). 

#### 3) Summarize gene annotations based on curated datasets to ascribe function to MAGs

After genes have been annotated, users can SUMMARIZE this information into a user-friendly excel workbook (metabolism_summary.xlsx), which contains consolidated gene counts for the most informative genes for specific metabolic functions(*Energy acquisition/bioenergetics, Assimilation & Cofactor Metabolism, Cellular Machinery & Environmental Interaction & Adaptation*). This information can be further refined using a user-defined ecosystem (*agriculture, engineered systems, biogeochemistry, and gut*) to provide the user with counts for a refined set of genes directly related to their ecosystem of interest. In addition to the metabolism_summary excel workbook, the SUMMARIZE which contains three key files: (1)  A genome statistics table which includes all statistics required to meet MIMAG criteria (genome_stats.tsv), (2) a metabolism summary sheet which gives gene counts of functional genes across a wide variety of metabolisms (summarized_genomes.tsv), and (3) a traits table which provides users with the information on the presence and absence of environmentally relevant pathways (traits.xlsx)

#### 4) Generate an interactive heatmap of ecosystem-relevant MAG level metabolic function

Users can also generate an interactive heatmap depicting the presence of specific metabolic functions. DRAM2 automatically generates this heatmap for each ecosystem if indicated by the user in addition to a generic heatmap of metabolic function by MAG if no ecosystem is defined
