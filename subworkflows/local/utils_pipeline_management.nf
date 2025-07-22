/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// Print pipeline summary on completion
//
def getCollateSize(job_size, input_fasta) {
    def n_input_fasta  = file(file(params.input_fasta) / "${params.fasta_fmt}").size()

    def n_by_queue = (int)(n_input_fasta/params.queue_size)  // cast to int to avoid decimal values
    if (n_by_queue < 1) {
        n_by_queue = 1  // Ensure at least one job is created
    }

    log.info "n_by_queue for ${job_size} jobs is set to ${n_by_queue}"
    switch(job_size) {
        case job_size == 'small' && params.batch_limit_sm_jobs_limit < n_by_queue:
            collate_size = params.batch_limit_sm_jobs_limit
        default:
            collate_size = n_by_queue
    }
    log.info "Collate size for ${job_size} jobs is set to ${collate_size}"
    return collate_size
}