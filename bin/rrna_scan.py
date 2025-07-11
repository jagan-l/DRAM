#!/usr/bin/env python
import argparse
import pandas as pd
import subprocess
import io
from sys import stderr
import os

from utils.logger import get_logger


logger = get_logger()

FASTA_COLUMN = os.getenv('FASTA_COLUMN')

def run_barrnap(fasta, input_fasta_name, threads, verbose=True):
    barrnap_command = [
        "barrnap",
        "--threads", str(threads),
        "--kingdom", "bacteria",  # Adjust as necessary
        fasta
    ]
    result = subprocess.run(barrnap_command, capture_output=True, text=True)
    raw_rrna_str = result.stdout

    if not raw_rrna_str.strip():
        logger.debug(f"No rRNAs were detected for {input_fasta_name}.", file=stderr)
        return pd.DataFrame(columns=[FASTA_COLUMN, "query_id", "type", "begin", "end", "strand", "e-value", "note"])  # Ensure this matches RRNA_COLUMNS

    try:
        rrna_df = pd.read_csv(
            io.StringIO(raw_rrna_str),
            sep="\t",
            header=None,
            names=["query_id", "tool_name", "type", "begin", "end", "strand", "e-value", "score", "note"],
            usecols=["query_id", "type", "begin", "end", "strand", "e-value", "note"],
            comment='#'  # This will skip lines starting with '#', including the '##gff-version 3' line
        )
        rrna_df.insert(0, FASTA_COLUMN, input_fasta_name)
        return rrna_df
    except pd.errors.ParserError:
        logger.error(f"Parser error processing barrnap output for {input_fasta_name}. Output may not be in the expected format.", file=stderr)
        return pd.DataFrame(columns=[FASTA_COLUMN, "query_id", "type", "begin", "end", "strand", "e-value", "note"])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run tRNAscan-SE and process its output.")
    parser.add_argument("--fasta_name", help="input fasta name")
    parser.add_argument("--fasta", help="input fasta file path")
    parser.add_argument("--output", help="Where the processed tRNAs will be saved", type=str, default="processed_rrnas.tsv")
    parser.add_argument("--threads", help="Number of threads for parallel processing", type=int, default=4)
    args = parser.parse_args()
    
    if args.fasta_name and args.fasta:
        rrna_df = run_barrnap(f"{args.fasta}", f"{args.fasta_name}", threads=f"{args.threads}", verbose=True)

        if not rrna_df.empty:
            rrna_df.to_csv(args.output, sep="\t", index=False)
        else:
            with open(args.output, "w") as file:
                file.write("NULL")
                
        logger.debug(f"Ran barnap and save output to {args.output}")

    else:
        logger.error("Missing required arguments. Use --help for usage information.")
