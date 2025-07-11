#!/usr/bin/env python
import argparse
import pandas as pd
import subprocess
import os

from utils.logger import get_logger


logger = get_logger()

FASTA_COLUMN = os.getenv('FASTA_COLUMN')

# Set TMPDIR to ./tmp
os.environ['TMPDIR'] = './tmp'

# Create the temporary directory if it doesn't exist
os.makedirs(os.environ['TMPDIR'], exist_ok=True)

def process_trnascan_output(input_file, output_file, input_fasta_name):
    try:
        # Read the input file into a DataFrame
        trna_frame = pd.read_csv(input_file, sep="\t", skiprows=[0, 2], engine='python')

        # Proceed with processing if trna_frame is not empty
        if not trna_frame.empty:
            # Strip leading and trailing spaces from column names
            trna_frame.columns = trna_frame.columns.str.strip()

            # Add a new FASTA_COLUMN column and populate it with the input_fasta_name value
            trna_frame.insert(0, FASTA_COLUMN, input_fasta_name)

            ## Check if "Note" column is present
            #if "Note" in trna_frame.columns:
            #    # Process the "Note" column to update the "Type" column
            #    trna_frame["Type"] = trna_frame.apply(lambda row: row["Type"] + " (pseudo)" if str(row["Note"]).lower().startswith("pseudo") else row["Type"], axis=1)

            #    # Drop the processed "Note" column
            #    trna_frame = trna_frame.drop(columns=["Note"])

            # Keep only the first occurrence of "Begin" and "End" columns
            trna_frame = trna_frame.loc[:, ~trna_frame.columns.duplicated(keep='first')]

            # Remove columns starting with "Begin" or "End"
            trna_frame = trna_frame.loc[:, ~trna_frame.columns.str.match('(Begin|End)\.')]

            # Rename specified columns
            trna_frame = trna_frame.rename(columns={"Name": "query_id", "Begin": "begin", "End": "end", "Type": "type", "Codon": "codon", "Score": "score", "Note": "note"})

            # Create the "gene_id" column by concatenating "type" and "codon"
            trna_frame["gene_id"] = trna_frame["type"] + " (" + trna_frame["codon"] + ")"

            # Check if DataFrame after processing is still not empty
            if not trna_frame.empty:
                # Write the processed DataFrame to the output file
                trna_frame.to_csv(output_file, sep="\t", index=False)
            else:
                # DataFrame is empty after processing, write "NULL" to output
                with open(output_file, "w") as f:
                    f.write("NULL")
        else:
            # Initial DataFrame is empty, write "NULL" to output
            with open(output_file, "w") as f:
                f.write("NULL")
    except pd.errors.EmptyDataError:
        # The input file is empty or only contains headers, write "NULL" to output
        with open(output_file, "w") as f:
            f.write("NULL")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run tRNAscan-SE and process its output.")
    parser.add_argument("--fasta_name", help="input fasta name")
    parser.add_argument("--fasta", help="input fasta file path")
    parser.add_argument("--output", help="Where the processed tRNAs will be saved", type=str, default="processed_trnas.tsv")
    parser.add_argument("--threads", help="Number of threads for parallel processing", type=int, default=4)
    args = parser.parse_args()
    
    if args.fasta_name and args.fasta:
        # combine_annotations(args.annotations, args.output, args.threads)
        # Run tRNAscan-SE with the necessary input to avoid prompts
        trna_out = f"{args.fasta_name}_trna_out.txt"
        subprocess.run(["tRNAscan-SE", "-G", "-o", trna_out, "--thread", f"{args.threads}", f"{args.fasta}"], input=b'O\n', check=True)

        # Process tRNAscan-SE output
        process_trnascan_output(trna_out, args.output, args.fasta_name)
        logger.debug(f"Processed tRNAscan-SE output and saved to {args.output}")

    else:
        logger.error("Missing required arguments. Use --help for usage information.")
