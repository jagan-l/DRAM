process RENAME_PROTEINS {
    label 'process_tiny'

    input:
    tuple val(fasta_names), path(fastas)

    output:
    tuple path("*_renamed_headers.tsv"), path("RENAMED_HEADERS/*"), emit: renamed_batch

    script:
    // def samples = fasta_names as List
    def manifest = "${task.process.tokenize(':').last()}_renamed_headers.tsv"

    def rename_cmds = fasta_names.indices.collect { i ->
        def name = fasta_names[i]
        def file = fastas[i]
        def ext = file.getExtension()
        def output = "${name}.${ext}"
        """
        rename_headers.py ${file} RENAMED_HEADERS ${name}
        printf '%s\\t%s\\n' '${name}' '${output}' >> ${manifest}
        """
    }.join("\n")

    """
    mkdir -p RENAMED_HEADERS
    : > ${manifest}
    ${rename_cmds}
    """
}
