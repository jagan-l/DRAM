process SUMMARIZE {
    label 'process_medium'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] ?
        'oras://community.wave.seqera.io/library/python_click_polars_pyarrow_pruned:67e7bc1132e4cf91' :
        'community.wave.seqera.io/library/python_click_polars_pyarrow_pruned:45e45e8e79698c99' }"

    input:
    path( ch_combined_annotations, stageAs: "raw-annotations.tsv" )
    path( ch_trna_combined)
    val( distill_topic )
    val( distill_ecosystem )
    val( distill_custom )

    output:
    path( "*.xlsx" ), emit: distillate
    path( "*.log" ), emit: log
    path( "summarized_genomes.tsv" ), emit: summarized_genomes

    script:
    """
    # export constants for script
    export FASTA_COLUMN="${params.CONSTANTS.FASTA_COLUMN}"

    distill.py -i ${ch_combined_annotations} --trna_path '${ch_trna_combined}' --distill_topics "${distill_topic}" --distill_ecosystem "${distill_ecosystem}" --custom_distillate "${distill_custom}"

    """
}
