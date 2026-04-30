process GENE_LOCS {
    label 'process_single'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_polars_hmmer_pruned:6d5bc9dfeca29b70"

    tag { input_fasta }

    input:
    tuple val( input_fasta ), path( genes )

    output:
    tuple val( input_fasta ), path( "${input_fasta}_called_genes_table.tsv" ), emit: prodigal_locs_tsv


    script:

    """
    parse_faa.sh ${genes} "${input_fasta}_called_genes_table.tsv"
    """
}
