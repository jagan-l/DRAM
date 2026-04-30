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


def checkDBVersion(version_file, db_version, db_name) {
    if (version_file == null) {
        error("Version file for DB ${db_name} undefined as set to null. This could mean you did not defined everything for you configuration, or are missing your configuration file in the DRAM path or on the command line.\nIt could also mean your configuration file is out of date and new parameters have been added or removed.")
    }
    version_file = file(version_file)
    if (!version_file.exists()) {
        error("Version file for DB ${db_name} not found at: ${version_file}")
    }
    version_file.withReader { r ->
        def version = r.readLine()
        if (version != db_version) {
            error("Version for DB ${db_name} did not match expected version: ${db_version}. Version found: ${version}. \nYou can install the latest version of the database from GLOBUS and update DRAM as well if need be.")
        }
    }
}
