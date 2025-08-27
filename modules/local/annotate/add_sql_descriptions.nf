process ADD_SQL_DESCRIPTIONS {
    label 'process_single'

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_hmmer_mmseqs2_pruned:f459942a75c71501"

    input:
    tuple val(input_fasta), path(hits_file)
    val(db_name)
    file(ch_sql_descriptions_db)

    output:
    tuple val(input_fasta), path("${input_fasta}___sql_formatted_${db_name}_hits.csv"), emit: sql_formatted_hits

    script:
    """
    sql_add_descriptions.py --hits_csv ${hits_file} --db_name ${db_name} --output "${input_fasta}___sql_formatted_${db_name}_hits.csv" --db_file ${ch_sql_descriptions_db}
    """
}
