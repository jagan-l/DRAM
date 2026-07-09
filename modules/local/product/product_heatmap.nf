process PRODUCT_HEATMAP {
    label 'process_small'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_dram-viz:ac93dd7d16cc1dd4"

    input:
    path(ch_final_annots, stageAs: "raw-annotations.tsv")
    val(fasta_column)
    path(rules_tsv)
    path(mapping_file)
    val(rules_system)

    output:
    path( "product.html" ), emit: product_html

    script:
    def args = task.ext.args ?: ''
    def viz_rules_tsv = rules_tsv ? "--rules_tsv $rules_tsv" : ''
    def viz_mapping_file = mapping_file ? "--mapping $mapping_file" : ''
    def viz_rules_system = rules_system ? "--rules_system $rules_system" : ''
    """
    dram_viz \\
        --annotations ${ch_final_annots} \\
        --fasta_column ${fasta_column} \\
        $viz_rules_tsv \\
        $viz_mapping_file \\
        $viz_rules_system \\
        $args
    """
}
