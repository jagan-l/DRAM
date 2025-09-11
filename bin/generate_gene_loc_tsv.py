#!/usr/bin/env python
import sys
from skbio.io import read as read_sequence
import pandas as pd

def parse_prodigal_output(prod_out_file, output_path):
    rows = []
    for seq_id, im in read_sequence(prod_out_file, format="gff3"):
        for i, iv in enumerate(im.query(metadata={'type': 'CDS'})):
            start0, end0 = iv.bounds[0]
            gene_number = i + 1
            rows.append({
                "query_id": f"{seq_id}_{gene_number}",
                "start_position": start0 + 1,     # 1-based inclusive
                "stop_position": end0,             # 1-based inclusive end
                "strandedness": 1 if iv.metadata.get("strand", ".") == "+" else -1,
                "gene_number": gene_number,
            })

    df = pd.DataFrame(rows)
    df.to_csv(output_path, sep='\t', index=False)

if __name__ == "__main__":
    prodigal_output_file = sys.argv[1]
    output_path = sys.argv[2]
    parse_prodigal_output(prodigal_output_file, output_path)
