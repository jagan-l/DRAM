process RRNA_SCAN {
    label 'process_low'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_barrnap_trnascan-se:ed2ab26abf39304b"

    tag { input_fasta }

    input:
    val input_fasta
    path fasta

    output:
    path("${input_fasta}_processed_rrnas.tsv"), emit: rrna_scan_out, optional: true

    script:
    """
    # export constants for script
    export FASTA_COLUMN="${params.CONSTANTS.FASTA_COLUMN}"

    rrna_scan.py --fasta_name "${input_fasta}" --fasta "${fasta}" --output "${input_fasta}_processed_rrnas.tsv" --threads ${params.threads}
    """
}
