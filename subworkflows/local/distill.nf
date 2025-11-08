//
// Subworkflow with functionality specific to the WrightonLabCSU/dram pipeline
//

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { SUMMARIZE as SUMMARIZE_SCRIPT                         } from "${projectDir}/modules/local/distill/distill.nf"
include { COMBINE_SUMMARIZE                                   } from "${projectDir}/modules/local/distill/combine_distill.nf"

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SUBWORKFLOW TO SUMMARIZE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow SUMMARIZE {
    take:
    ch_final_annots
    ch_rrna_combined
    ch_trna_combined


    main:

    // Generate multi-sheet XLSX document containing annotations included in user-specified distillate speadsheets

    SUMMARIZE_SCRIPT( ch_final_annots, ch_rrna_combined, ch_trna_combined )
    ch_distillate = SUMMARIZE_SCRIPT.out.distillate


}