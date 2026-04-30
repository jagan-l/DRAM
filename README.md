# DRAM2

## Welcome to the wiki for Distilling and Refining Annotations of Metabolism 2 (DRAM2)!
Here you will find all you need to know to setup, install and run DRAM2. This page will give you basic instructions, but if you want more detail on how DRAM2 works or what all DRAM2 options mean then be sure to check out the other pages in the wiki

<p align="center">
 <img src="assets/images/DRAM2_large.png" width="600" height="600" alt="DRAM v2 logo">
</p>

## ⚠️ DRAM v2 is currently under active development and usage is at your own risk. ⚠️

## DRAM2 Overview
DRAM2 (Distilling and Refining Annotations of Metabolism, version 2) is a tool for annotating genomic and metagenomic assemblies (e.g., scaffolds or contigs) as well as predicted genes (nucleotide or amino acid sequences). It organizes genome annotations into metabolic functions across three levels of increasing interpretation: (1) **ANNOTATE**, (2) **SUMMARIZE**, and (3) **VISUALIZE**. This workflow enables the analysis of large numbers of microbial genomes or metagenomes, highlighting functional guilds and supporting inference of organismal metabolism across datasets.

During the **ANNOTATE** stage, DRAM2 identifies genes in input sequences and annotates them using multiple databases, including [KEGG](https://www.kegg.jp/) (if provided by the user), [UniRef90](https://www.uniprot.org/), [PFAM](https://pfam.xfam.org/), [dbCAN3](http://bcb.unl.edu/dbCAN2/), [RefSeq Viral](https://www.ncbi.nlm.nih.gov/genome/viruses/), [VOGDB](http://vogdb.org/), [MEROPS](https://www.ebi.ac.uk/merops/), and optional user-defined databases. A full list of available annotation databases can be found here: [WrightonLabCSU/dram pipeline parameters](https://dramit.readthedocs.io/en/latest/params_doc.html#pipeline-steps). ANNOTATE then integrates results across all databases, increasing annotation coverage and yielding ~25% more database hits than commonly used annotators such as DFAST, MetaERG, and Prokka.

The **ANNOTATE** output contains all database hits for every gene in each genome, generating a comprehensive output of most annotation pipelines. DRAM2 extends beyond this by organizing (**SUMMARIZE**) and visualizing (**VISUALIZE**) annotations into ecosystem-relevant functional categories, enabling more interpretable comparisons across genomes and ecosystems.

## DRAM2 Overview & Example Usage

### DRAM2 for Genomes
After gene calling in Prodigal, DRAM2 annotates genes in each genome (or Metagenome Assembled Genome (MAG)) using a suite of user-defined databases. The output of this step (“raw-annotations.tsv”) contains all database annotations. DRAM2 also generates the ANNOTATE folder containing: (1) the annotated nucleotide and amino acid fasta files of all genes, (2) genome quality data generated using Quast, (3) .gff files for each genome, and (4) database-specific files produced during the gene annotation process (i.e. HMMsearch output, MMseq2s output, dbcan3-hmm and dbcan3SUB-hmm etc). DRAM2 also generates the SUMMARIZE folder, which contains three key files: (1)  A genome statistics table which includes all statistics required by MIMAG, (2) a metabolism summary sheet which gives gene counts of functional genes across a wide variety of metabolisms, and (3) a summarized genomes table which gives pathway presence information per MAGs. Finally, DRAM2 generates the VISUALIZE folder. This contains a visualization of your data as an interactive heatmap showing coverage of modules, the coverage of electron transport chain components and the presence of selected metabolic functions. Here is a standard full workflow to run DRAM2 for genomes. Here, we are annotating a directory of genomes, renaming them for downstream use, calling genes and annotating them using all available databases, performing quality control, summarizing and visualizing with particular ecosystems in mind. The command is submitted on the command line and will run in the background

``` bash
nextflow run WrightonLabCSU/DRAM --input_fasta [INPUT_FASTA] --outdir [OUTPUT_DIR] --rename --call --annotate --anno_dbs all --qc --summarize --sum_ecos 'eng_sys,ag' --visualize -profile singularity -resume --slurm -bg
```
please note that '--input_fasta [INPUT_FASTA]' should be a directory of genomes or MAGs in .fa or .fna format

### DRAM2 for Assemblies
DRAM2 can also be used to annotate genes from metagenome assemblies. Similar to DRAM2 for MAGs, genes first are called in Prodigal, and then annotated using user-defined databases. The outputs for this ANNOTATE step are similar in function to the ANNOTATE output for DRAM2 for MAGs. A key difference between these two pipelines, though, is that the SUMMARIZE and VISUALIZE functions are meant to show genome-scale functions and take into account synteny and gene order. As such, the SUMMARIZE and VISUALIZE outputs should be interpreted with caution when running DRAM2 on genes. Here is a standard full workflow to run DRAM2 for assemblies:

``` bash
nextflow run WrightonLabCSU/DRAM --input_fasta [INPUT_FASTA] --outdir [OUTPUT_DIR] --rename --call --annotate --anno_dbs all 
-profile singularity -resume --slurm -bg
```


## Other DRAM2 functions
DRAM2 is a flexible tool, allowing users to call, annotate, vizualize, and summarize genomes and genes as separate steps, rename fasta headers, merge annotations, and define annotation databases and ecosystem outputs. For more example commands and all available parameters, please see [Docs](https://dramit.readthedocs.io/en/latest)

1. **Rename fasta headers based on input sample file names:**

```bash
nextflow run WrightonLabCSU/DRAM --rename --input_fasta <path/to/fasta/directory/>
```

2. **Call genes using input fastas (use --rename to rename FASTA headers):**

```bash
nextflow run WrightonLabCSU/DRAM --call --rename --input_fasta <path/to/fasta/directory/>
```

3. **Annotate called genes using input called genes and just one database:**

```bash
nextflow run WrightonLabCSU/DRAM --annotate --input_genes <path/to/called/genes/directory> --use_kofam
```

4. **Annotate called genes using input fasta files and the KOFAM database:**

```bash
nextflow run WrightonLabCSU/DRAM --annotate --input_fasta <path/to/called/genes/directory> --use_kofam
```

5. **Merge existing DRAM or DRAM2 annotations files:**

```bash
nextflow run WrightonLabCSU/DRAM --merge_annotations <path/to/directory/with/multiple/annotation/TSV/files>
```

6. **Distill using input annotations:**

```bash
nextflow run WrightonLabCSU/DRAM --distill_<topic|ecosystem|custom> --annotations <path/to/annotations.tsv>
```


## For more detailed information on DRAM and DRAM2 please see our DRAM other products:
- [DRAM version 1 publication](https://academic.oup.com/nar/article/48/16/8883/5884738)
- [DRAM in KBase publication](https://pubmed.ncbi.nlm.nih.gov/36857575/)
- [DRAM webinar](https://www.youtube.com/watch?v=-Ky2fz2vw2s)

## Quick Links
- [Docs](https://dramit.readthedocs.io/en/latest)
- [Installation Guide](https://dramit.readthedocs.io/en/latest/installation.html)
- [Usage Examples](https://dramit.readthedocs.io/en/latest/usage.html)
- [Parameter API](<[#command-line-options](https://dramit.readthedocs.io/en/latest/params_doc.html)>)
- [Rules API](<[#nextflow-tips-and-tricks](https://dramit.readthedocs.io/en/latest/rules_parser.html)>)


## Nextflow Tips and Tricks

The `-resume` option in Nextflow DSL2 allows you to efficiently manage and modify your workflow runs:

- **Adding databases to an existing run:**
  - Using `-resume` with your existing work directory lets you reuse called genes and existing annotations
  - Example: If you initially used `--use_kofam --use_dbcan`, you can add `--use_kegg --use_uniref` and only the new annotations will be computed

## Resource Management

DRAM leverages Nextflow's horizontal scaling capabilities to distribute computational tasks across multiple computing resources. You can customize resource allocation through the `nextflow.config` file:

- Modify "maxForks" parameters to control parallel execution
- Configure CPU and memory requirements per process
- Coming soon: "lite", "medium" and "heavy" modes for different computing environments

## Configuration

Every CLI option can be set in the `nextflow.config` file. For example:

```nextflow
params {
    use_uniref = true
    annotate = true
}
```

You can also use a custom config file:

```bash
nextflow run DRAM -c /path/to/custom_config.config
```

## Citing DRAM

If DRAM helps you in your research, please cite:
[DRAM publication in Nucleic Acids Research (2020)](https://academic.oup.com/nar/article/48/16/8883/5884738)
