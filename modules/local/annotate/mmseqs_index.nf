process MMSEQS_INDEX{
    label 'process_low'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_hmmer_mmseqs2_pruned:f459942a75c71501"
    
    input:
    // path fastas, stageAs: "combined_genes.faa"
    tuple path( fastas ), path( gene_locs )

    output:
    path( "*.mmsdb*" ), emit: mmseqs_index_out
    tuple path( "*.mmsdb*" ), path( gene_locs ), emit: mmseqs_index_out_tuple

    script:

    """
    # Create temporary directory
    mkdir -p mmseqs_out/tmp

    mmseqs createdb ${fastas} combined_genes.mmsdb
    mmseqs createindex combined_genes.mmsdb mmseqs_out/tmp --threads ${params.threads}
    """


}