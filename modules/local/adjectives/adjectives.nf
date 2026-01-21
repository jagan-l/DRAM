process ADJECTIVES {
    label 'process_small'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_click_polars_numpy_lark:a5ca0b0b603e3581"

    input:
    path( ch_combined_annotations, stageAs: "raw-annotations.tsv" )
    path( rules_tsv )

    output:
    path("adjectives.tsv"), emit: adjectives_ch

    script:
    def args = task.ext.args ?: ""

    """
    # export constants for script
    export FASTA_COLUMN="${params.CONSTANTS.FASTA_COLUMN}"

    adjectives.py --annotations ${ch_combined_annotations} --output traits.tsv --rules_tsv '${rules_tsv}' ${args}
    """
}
