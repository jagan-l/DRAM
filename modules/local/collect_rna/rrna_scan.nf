process RRNA_SCAN {
    label 'process_low'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_barrnap_trnascan-se_click:1673b0631658b61b"

    input:
    val fasta_names
    path fastas

    output:
    path("*_processed_rrnas.tsv"), emit: rrna_scan_out, optional: true

    script:

    def fasta_paths = ""
    def names = ""

    fasta_names.indices.collect { i ->
        fasta_paths += "${fastas[i]},"
        names += "${fasta_names[i]},"
    }
    fasta_paths = fasta_paths[0..-2] // remove trailing comma
    names = names[0..-2] // remove trailing comma

    """
    # export constants for script
    export FASTA_COLUMN="${params.CONSTANTS.FASTA_COLUMN}"

    rrna_scan.py --fasta_name "${names}" --fasta "${fasta_paths}" --threads ${params.threads}
    """
}
