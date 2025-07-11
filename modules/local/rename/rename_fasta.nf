process RENAME_FASTA {
    label 'process_tiny'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/bbmap:801715ef64484762"

    input:
    val fasta_names
    path fastas

    output:
    path("renamed/*.fna"), emit: renamed_fasta_paths
    // tuple val(input_fasta), path("*.fna"), emit: renamed_fasta

    script:

    def rename_cmds = fasta_names.indices.collect { i ->
        def name = fasta_names[i]
        def file = fastas[i]
        "rename.sh in=${file} out=renamed/${name}.fna prefix=${name} addprefix=t"
    }.join("\n")


    """
    mkdir -p renamed
    ${rename_cmds}
    echo "Renaming completed for ${fasta_names.size()} FASTA files."
    """
}
