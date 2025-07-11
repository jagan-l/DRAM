process COLLECT_RRNA_TRNA {
    label 'process_low'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_barrnap_trnascan-se_click:1673b0631658b61b"

    tag { input_fasta }

    input:
    val fasta_names
    path fastas

    output:
    path("${input_fasta}_processed_rrnas.tsv"), emit: rrna_scan_out, optional: true

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
    # export constants for script
    export FASTA_COLUMN="${params.CONSTANTS.FASTA_COLUMN}"

    rrna_scan.py --fasta_name "${input_fasta}" --fasta "${fasta}" --output "${input_fasta}_processed_rrnas.tsv" --threads ${params.threads}
    """
}
