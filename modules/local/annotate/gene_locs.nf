process GENE_LOCS {
    label 'process_single'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_hmmer_mmseqs2_pruned:0a22b52d960467a9"

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
