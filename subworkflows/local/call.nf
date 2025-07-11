//
// Subworkflow with functionality specific to the WrightonLabCSU/dram pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { CALL_GENES                                    } from "${projectDir}/modules/local/call/call_genes_prodigal.nf"
include { QUAST                                         } from "${projectDir}/modules/local/call/quast.nf"
include { QUAST_COLLECT                                 } from "${projectDir}/modules/local/call/quast_collect.nf"
include { getCollateSize                                } from "${projectDir}/subworkflows/local/utils_pipeline_management.nf"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SUBWORKFLOW TO CALL PRODIGAL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow CALL {
    take:
    ch_fasta_name // channel: val(input_fasta names)
    ch_fasta  // channel: path(fasta)

    main:

    // Call genes using Prodigal on the input fasta file(s) 1-by-1
    def collate_size = getCollateSize("small", ch_fasta_name)
    CALL_GENES ( ch_fasta_name.collate(collate_size), ch_fasta.collate(collate_size) )
    // CALL_GENES ( ch_fasta_name.collate(1), ch_fasta.collate(1) )

    // We call flatten because collate could group them into lists if size is too small and has to be broken into multiple jobs
    ch_called_genes = CALL_GENES.out.prodigal_fna.flatten()
    ch_called_proteins = CALL_GENES.out.prodigal_faa.flatten()
    ch_gene_locs = CALL_GENES.out.prodigal_locs_tsv.flatten()
    ch_gene_gff = CALL_GENES.out.prodigal_gff.flatten()
    ch_filtered_fasta = CALL_GENES.out.prodigal_filtered_fasta.flatten()

    Channel.empty()
        .mix( ch_called_genes  )
        .collect()
        .set { ch_collected_fna }

    // Collect all individual fasta to pass to quast
    Channel.empty()
        .mix( ch_filtered_fasta, ch_gene_gff  )
        .collect()
        .set { ch_collected_fasta }

    if (params.rename) {
        ch_fasta = CALL_GENES.out.renamed_fasta_paths.flatten()
    }
    if (params.call) {
        // // Collect all individual fasta to pass to quast
        // ch_called_proteins
        //     .collect()                  // Collect all paths into a list
        //     .set { ch_collected_faa }   // Set the resulting list to ch_collected_faa

        // Collect all individual fasta to pass to quast

        // Run QUAST on individual FASTA file combined with respective GFF
        QUAST( ch_collected_fasta )
        ch_quast_stats = QUAST.out.quast_collected_out
    }

    emit:
    // ch_quast_stats
    ch_gene_locs  // channel: path(gene_locs_tsv)
    ch_called_genes // channel: path(called_genes_file.fna)
    ch_called_proteins  // channel: path(called_proteins_file.faa)
    // ch_collected_faa  
    ch_collected_fna
    ch_collected_fasta
    ch_fasta
}
