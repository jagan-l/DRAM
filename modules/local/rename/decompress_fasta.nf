process DECOMPRESS_FASTA {
    label 'process_tiny'

    tag { name }

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] ?
        'oras://community.wave.seqera.io/library/bbmap:eecc2d5093684dba' :
        'community.wave.seqera.io/library/bbmap:801715ef64484762' }"

    input:
    tuple val(name), path(fasta_gz)

    output:
    tuple val(name), path("DECOMPRESSED/${name}.fa"), emit: decompressed_fasta

    script:
    """
    mkdir -p DECOMPRESSED
    reformat.sh in=${fasta_gz} out=DECOMPRESSED/${name}.fa
    """
}
