process CALL_GENES {
    label 'process_low'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_scikit-bio_hmmer_pruned:8167823ba0a9349d"

    input:
    val fasta_names
    path fastas
    // tuple val( fasta_names ), path( fastas )

    output:
    path("renamed/*.fna"), emit: renamed_fasta_paths, optional: true
    path( "*.fna" ), emit: prodigal_fna, optional: true
    path( "*.faa" ), emit: prodigal_faa, optional: true
    path( "*.tsv" ), emit: prodigal_locs_tsv, optional: true
    path( "*.fa" ), emit: prodigal_filtered_fasta, optional: true
    path( "*.gff" ), emit: prodigal_gff, optional: true
    tuple val(task.index), path( "*.fna" ), path( "*.faa" ), path( "*.tsv" ), path( "*.fa" ), path( "*.gff" ), emit: ch_combined_call_output, optional: true
    tuple path( "*.faa" ), path( "*.tsv" ), emit: ch_combined_call_gene_output, optional: true

    script:

    def rename_cmds = ""
    def cat_cmd = ""
    def call_prodigal_cmd = ""

    if (params.rename) {

        def cmds = fasta_names.indices.collect { i ->
            def name = fasta_names[i]
            def file = fastas[i]
            "rename.sh in=${file} out=renamed/${name}.fna prefix=${name} addprefix=t"
        }.join("\n")
        rename_cmds = """
        mkdir -p renamed
        ${cmds}
        """
        // Replace the fastas file with the renamed file
        fastas = fasta_names.indices.collect { i -> "renamed/${fasta_names[i]}.fna" }

        cat_cmd = "cat renamed/*.fna > tmp/combined_genes.fna"

    } else {
        // If not renaming, we assume the input fastas are already named correctly
        cat_cmd = "cat ${fastas.join(' ')} > tmp/combined_genes.fna"
    }

    if (params.call) {
        call_prodigal_cmd = """
            ${cat_cmd}

            reformat.sh \\
            in=tmp/combined_genes.fna \\
            out="combined_${task.index}_${params.min_contig_len}.fa" \\
            minlength=${params.min_contig_len}

            
            if [ ! -s "combined_${task.index}_${params.min_contig_len}.fa" ]; then
                echo "Sample combined_${task.index}_${params.min_contig_len}.fa - Error: no contigs after filtering for minimum contig length (${params.min_contig_len})"
            else
                prodigal \\
                -i "combined_${task.index}_${params.min_contig_len}.fa" \\
                -o "combined_${task.index}_called_genes.gff" \\
                -p ${params.prodigal_mode} \\
                -g ${params.prodigal_trans_table} \\
                -f gff \\
                -d "combined_${task.index}_called_genes.fna" \\
                -a "combined_${task.index}_called_genes.faa"

                if [ ! -s "combined_${task.index}_called_genes.gff" ]; then
                    echo "Sample combined_${task.index} - Warning: called genes GFF file is empty or does not exist."
                    # Consider managing absent output files for downstream processes here
                else
                    generate_gene_loc_tsv.py "combined_${task.index}_called_genes.gff" > "combined_${task.index}_called_genes_table.tsv"
                fi
                
                echo "Sample combined_${task.index} - Finished calling genes with Prodigal."
            fi

            """
    }

    """
    mkdir tmp
    ${rename_cmds}
    ${call_prodigal_cmd}

    """
}
