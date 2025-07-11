#!/usr/bin/env python
import argparse
import pandas as pd
import subprocess
import io
from sys import stderr
import os
import click

from utils.logger import get_logger
from utils.click_utils import validate_comma_separated


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

@click.command()
@click.option("--fasta_name", help="Input fasta name. Can include more than one as a comma seperated list", default=[], callback=validate_comma_separated, required=True)
@click.option("--fasta", help="Input fasta file path.  Can include more than one as a comma seperated list", default=[], callback=validate_comma_separated, required=True)
@click.option("--threads", help="Number of threads for parallel processing", type=int, default=4)
def main(fasta_name, fasta, threads):
    """Run barrnap and process its output."""
    assert len(fasta_name) == len(fasta), "fasta_name and fasta must have the same number of elements"
    for name, file in zip(fasta_name, fasta):
        assert name, "fasta_name cannot be empty"
        assert file, "fasta cannot be empty"
        
        output = f"{name}_processed_rrnas.tsv"

        rrna_df = run_barrnap(file, name, threads=threads, verbose=True)

        if not rrna_df.empty:
            rrna_df.to_csv(output, sep="\t", index=False)
        else:
            with open(output, "w") as file:
                file.write("NULL")
                
        logger.debug(f"Ran barrnap and saved output to {output}")

if __name__ == "__main__":
    main()
