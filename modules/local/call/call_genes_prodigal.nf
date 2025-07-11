process CALL_GENES {
    label 'process_low'

    errorStrategy 'finish'

    // tag { input_fasta }

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_scikit-bio_hmmer_pruned:ef64c488c99048d6"

    input:
    val fasta_names
    path fastas
    // tuple val( input_fasta ), path( fasta )

    output:
    // path("renamed/*.fna"), emit: renamed_fasta_paths, optional: true
    path( "*.fna" ), emit: prodigal_fna, optional: true
    path( "*.faa" ), emit: prodigal_faa, optional: true
    path( "*.tsv" ), emit: prodigal_locs_tsv, optional: true
    path( "*.fa" ), emit: prodigal_filtered_fasta, optional: true
    path( "*.gff" ), emit: prodigal_gff, optional: true


    script:

    def call_prodigal_cmds = fasta_names.indices.collect { i ->
        def name = fasta_names[i]
        def fasta_file = fastas[i]
        """

        reformat.sh \\
        in=${fasta_file} \\
        out="${name}_${params.min_contig_len}.fa" \\
        minlength=${params.min_contig_len}

        
        if [ ! -s "${name}_${params.min_contig_len}.fa" ]; then
            echo "Sample ${i} - ${name} - Error: no contigs after filtering for minimum contig length (${params.min_contig_len})"
        else
            prodigal \\
            -i "${name}_${params.min_contig_len}.fa" \\
            -o "${name}_called_genes.gff" \\
            -p ${params.prodigal_mode} \\
            -g ${params.prodigal_trans_table} \\
            -f gff \\
            -d "${name}_called_genes.fna" \\
            -a "${name}_called_genes.faa"

            if [ ! -s "${name}_called_genes.gff" ]; then
                echo "Sample ${name} - Warning: called genes GFF file is empty or does not exist."
                # Consider managing absent output files for downstream processes here
            else
                generate_gene_loc_tsv.py "${name}_called_genes.gff" > "${name}_called_genes_table.tsv"
            fi
            
            echo "Sample ${i} - ${name} - Finished calling genes with Prodigal."
        fi

        """
    }.join("\n")

    """
    ${call_prodigal_cmds}
    """
}
