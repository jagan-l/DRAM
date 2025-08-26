process COMBINE_ANNOTATIONS {
    label 'process_small'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_hmmer_mmseqs2_pruned:f459942a75c71501"

    input:
    path(fastas)
    path(genes)

    // tuple val( input_fasta ), path( fastas )
    // tuple val( input_fasta_again ), path( genes )
    // tuple path(fastas), path(genes)

    output:
    path "raw-annotations.tsv", emit: combined_annotations_out
    path( "*.log" ), emit: log

    script:
    """
    # export constants for script
    export FASTA_COLUMN="${params.CONSTANTS.FASTA_COLUMN}"

    combine_annotations.py --annotations "${fastas}" --threads "${params.threads}" --output "raw-annotations.tsv" --genes_faa "${genes}"

    """
}
