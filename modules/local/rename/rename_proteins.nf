process RENAME_PROTEINS {
    label 'process_tiny'

    tag { "renaming_proteins" }

    input:
    val fasta_names
    path fastas

    output:
    path("RENAMED_HEADERS/*.faa"), emit: renamed_paths

    script:
    // def samples = fasta_names as List

    def rename_cmds = fasta_names.indices.collect { i ->
        def name = fasta_names[i]
        def file = fastas[i]
        "rename_headers.py ${file} RENAMED_HEADERS/${name}.faa ${name}"
    }.join("\n")

    """
    mkdir -p RENAMED_HEADERS
    ${rename_cmds}
    """
}
