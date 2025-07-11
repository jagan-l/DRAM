/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// Print pipeline summary on completion
//
def getCollateSize(job_size, input_fasta) {
    def n_by_queue = 1
    input_fasta.count().map { n ->
        n_input_fasta = n
        n_by_queue = (int)(n_input_fasta/params.queue_size)  // cast to int to avoid decimal values
        if (n_by_queue < 1) {
            n_by_queue = 1  // Ensure at least one job is created
        }
    }
    
    switch(job_size) {
        case job_size == 'small' && params.batch_limit_sm_jobs_limit < n_by_queue:
            collate_size = params.batch_limit_sm_jobs_limit
        default:
            collate_size = n_by_queue
    }
    return collate_size
}