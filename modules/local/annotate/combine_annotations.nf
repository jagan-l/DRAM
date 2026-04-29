process COMBINE_ANNOTATIONS {
    label 'process_small'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_polars_hmmer_pruned:6d5bc9dfeca29b70"

    input:
    path(fastas, stageAs: "annotations/*" )
    path(genes, stageAs: "genes/*" )
    path(dbcan_output, stageAs: "dbcan/*")

    output:
    path "raw-annotations.tsv", emit: combined_annotations_out
    path( "*.log" ), emit: log

    script:
    """
    export FASTA_COLUMN="${params.CONSTANTS.FASTA_COLUMN}"

    combine_annotations.py \\
        --annotations_dir annotations \\
        --genes_dir genes \\
        --dbcan_dir dbcan \\
        --output raw-annotations.tsv

    """
}
