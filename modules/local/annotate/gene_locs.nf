process GENE_LOCS {
    label 'process_single'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_hmmer_mmseqs2_pruned:f459942a75c71501"
    
    input:
    val fasta_names
    path genes

    output:
    path( "*_called_genes_table.tsv" ), emit: prodigal_locs_tsv


    script:

    def gen_faa_cmds = fasta_names.indices.collect { i ->
        def name = fasta_names[i]
        def file = genes[i]
        """
        generate_faa_gene_loc_tsv.py ${file} "${name}_called_genes_table.tsv"
        echo "Gene locations TSV generated for ${name} from ${file}"
        """
    }.join("\n")

    """
    ${gen_faa_cmds}
    echo "Gene locations TSV generation completed for ${fasta_names.size()} FASTA files."
    """
}
