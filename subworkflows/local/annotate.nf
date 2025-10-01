include { RENAME_FASTA           } from "${projectDir}/modules/local/rename/rename_fasta.nf"
include { CALL                   } from "${projectDir}/subworkflows/local/call.nf"
include { COLLECT_RNA            } from "${projectDir}/subworkflows/local/collect_rna.nf"
include { DB_SEARCH              } from "${projectDir}/subworkflows/local/db_search.nf"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SUBWORKFLOW TO ANNOTATE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow ANNOTATE {
    take:
    ch_fasta  // channel: [ val(input_fasta name), path(fasta) ]
    default_sheet // Path to dummy sheet
    n_fastas // Number of FASTA files to process

    main:
    n_fastas = 0
    ch_rrna_combined = default_sheet
    ch_trna_combined = default_sheet
    ch_combined_annotations = default_sheet

    if (params.rename || params.call) {
        fasta_name = ch_fasta.map { it[0] }
        fasta_files = ch_fasta.map { it[1] }

        n_fastas = file("$params.input_fasta/${params.fasta_fmt}").size()
    }

    if( params.rename ) {
        // We need to use collect so that we pass all the fasta files to the rename process at once
        // Otherwise, it will try to rename each fasta file one at a time
        // Which since rename is so fast, will clog up job queues
        // so it is faster to rename all at once
        RENAME_FASTA( fasta_name.toList(), fasta_files.toList() )
        // we use flatten here to turn a list back into a channel
        renamed_fasta_paths = RENAME_FASTA.out.renamed_fasta_paths.flatten()
        // we need to recreate the fasta channel with the renamed fasta files
        ch_fasta = renamed_fasta_paths.map {
            fasta_name = it.getBaseName().replaceAll(/\./, '-')
            tuple(fasta_name, it)
        }
    }

    ch_quast_stats = default_sheet
    ch_gene_locs = default_sheet
    ch_called_proteins = default_sheet
    ch_collected_fna = default_sheet

    if (params.call){
        CALL( ch_fasta )
        ch_quast_stats = CALL.out.ch_quast_stats
        ch_gene_locs = CALL.out.ch_gene_locs
        ch_called_proteins = CALL.out.ch_called_proteins
        ch_collected_fna = CALL.out.ch_collected_fna

    }

    if (params.call || distill_flag){
        COLLECT_RNA( ch_fasta, default_sheet )
        ch_rrna_combined = COLLECT_RNA.out.ch_rrna_combined
        ch_trna_combined = COLLECT_RNA.out.ch_trna_combined
    }

    if (params.annotate){
        DB_SEARCH( ch_gene_locs, ch_called_proteins, default_sheet, n_fastas )
        ch_combined_annotations = DB_SEARCH.out.ch_combined_annotations
    }
    emit:
    ch_rrna_combined
    ch_trna_combined
    ch_combined_annotations

}