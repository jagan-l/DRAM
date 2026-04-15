include { logColours           } from '../nf-core/utils_nfcore_pipeline'
include { getWorkflowVersion           } from '../nf-core/utils_nfcore_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


def getDBFlag(db_list, db_name, value_for_all, db_path) {
    if (db_list.contains(value_for_all)) {
        if (!file(db_path).exists()) {
            log.warn("Database $db_name not found at path $db_path, skipping")
            return false
        }
        return true
    } else if (db_list.contains(db_name)) {
        return true
    } else {
        return false
    }
}
