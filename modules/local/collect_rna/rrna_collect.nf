process RRNA_COLLECT {
    label 'process_low'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_barrnap_trnascan-se:ed2ab26abf39304b"

    input:
    path combined_rrnas

    output:
    path("collected_rrnas.tsv"), emit: rrna_collected_out, optional: true
    path("combined_rrna_scan.tsv"), emit: rrna_combined_out, optional: true

    script:
    """

    # export constants for script
    export FASTA_COLUMN="${params.CONSTANTS.FASTA_COLUMN}"

    rrna_collect.py --rrna_dir "."
    """
}
