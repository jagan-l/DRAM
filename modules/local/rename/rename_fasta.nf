process RENAME_FASTA {
    label 'process_tiny'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] ?
        'oras://community.wave.seqera.io/library/bbmap:eecc2d5093684dba' :
        'community.wave.seqera.io/library/bbmap:801715ef64484762' }"

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
        def output = "${name}.fa"
        """
        rename.sh in=${file} out=RENAMED_HEADERS/${output} prefix=${name} addprefix=t
        printf '%s\\t%s\\n' '${name}' '${output}' >> ${manifest}
        """
    }.join("\n")


    """
    mkdir -p RENAMED_HEADERS
    : > ${manifest}
    ${rename_cmds}
    """
}
