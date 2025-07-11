process QUAST_COLLECT {

    errorStrategy 'finish'

    conda "${moduleDir}/environment.yml"
    container "community.wave.seqera.io/library/python_pandas_scikit-bio_hmmer_pruned:8167823ba0a9349d"

    input:
    file quast_tsv_files

    output:
    path("collected_quast.tsv"), emit: quast_collected_out, optional: true

    script:
    """
    #!/usr/bin/env python

    import os
    import pandas as pd
    import re

    # List all tsv files in the current directory
    tsv_files = [f for f in os.listdir('.') if f.endswith('.tsv')]

    # Extract input_fasta names from the file names
    input_fastas = [os.path.basename(file).replace("_report.tsv", "") for file in tsv_files]


    """

}