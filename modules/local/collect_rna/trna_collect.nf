#!/usr/bin/env nextflow

process TRNA_COLLECT {
    label 'process_low'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_barrnap_trnascan-se_click:1673b0631658b61b"

    input:
    path combined_trnas

    output:
    path("collected_trnas.tsv"), emit: trna_collected_out, optional: true
    path("combined_trna_scan.tsv"), emit: trna_combined_out, optional: true

    script:
    """
    # export constants for script
    export FASTA_COLUMN="${params.CONSTANTS.FASTA_COLUMN}"

    trna_collect.py --trna_dir "."
    """
}
