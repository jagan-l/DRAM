#!/usr/bin/env python
import argparse
import os
import pandas as pd
from collections import defaultdict
import re

from utils.logger import get_logger


logger = get_logger()

FASTA_COLUMN = os.getenv('FASTA_COLUMN')

parser = argparse.ArgumentParser(description="Run tRNAscan-SE and process its output.")
parser.add_argument("--rrna_dir", help="directory containing processed rRNA files", type=str, default=".")
args = parser.parse_args()

def extract_rrna_gene_id(note):
    match = re.search(r'Name=(\w+)_rRNA', note)
    if match:
        return f"{match.group(1)} rRNA"
    return 'Unknown rRNA'

tsv_files = [f for f in os.listdir(args.rrna_dir) if f.endswith('_processed_rrnas.tsv')]
input_fastas = [os.path.basename(f).replace('_processed_rrnas.tsv', '') for f in tsv_files]
gene_type_counts = defaultdict(lambda: defaultdict(int))
combined_data = []
all_files_null = True

for file in tsv_files:
    with open(file, 'r') as f:
        contents = f.read().strip()
        if contents == 'NULL':
            continue
        all_files_null = False
        df = pd.read_csv(file, sep='\t')
        for index, row in df.iterrows():
            gene_id = extract_rrna_gene_id(row['note'])
            gene_type_counts[gene_id][row[FASTA_COLUMN]] += 1
        combined_data.append(df)

if all_files_null:
    with open('collected_rrnas.tsv', 'w') as f: f.write('NULL')
    with open('combined_rrna_scan.tsv', 'w') as f: f.write('NULL')
else:
    collected_data = []
    for gene_id, input_fastas_counts in gene_type_counts.items():
        row = {'gene_id': gene_id, 'gene_description': f"{gene_id} gene", 'category': 'rRNA', 'topic_ecosystem': '', 'subcategory': ''}
        for input_fasta in input_fastas: row[input_fasta] = input_fastas_counts.get(input_fasta, 0)
        collected_data.append(row)
    collected_df = pd.DataFrame(collected_data)
    collected_df.to_csv('collected_rrnas.tsv', sep='\t', index=False)
    combined_df = pd.concat(combined_data, ignore_index=True)
    combined_df.to_csv('combined_rrna_scan.tsv', sep='\t', index=False)
