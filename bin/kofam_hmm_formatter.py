#!/usr/bin/env python
import pandas as pd
import re
import click

def extract_ec_numbers(definition):
    """
    Extract EC numbers from the definition string and format them into a semi-colon separated list.
    Each EC number is prefixed with 'EC:'.
    """
    # This regex pattern looks for EC numbers within square brackets and captures the numbers following "EC:"
    ec_numbers = re.findall(r'\[EC:(.*?)\]', definition)
    # Join the EC numbers with semi-colon separator and prepend 'EC:' to each number
    formatted_ec_numbers = '; '.join([f"EC:{ec.strip()}" for ec_block in ec_numbers for ec in ec_block.split()])
    return formatted_ec_numbers

def calculate_bit_score(row):
    """Calculate bit score for each row."""
    return row['full_score'] / row['domain_number']

def calculate_rank(row):
    """Calculate rank for each row."""
    return row['score_rank'] if 'score_rank' in row and row['full_score'] > row['score_rank'] else row['full_score']

def calculate_perc_cov(row):
    """Calculate percent coverage for each row."""
    return (row['target_end'] - row['target_start']) / row['target_length']

def find_best_hit(df):
    """Find the best hit based on E-value and coverage."""
    df['perc_cov'] = (df['target_end'] - df['target_start']) / df['target_length']
    df.sort_values(by=["full_evalue", "perc_cov"], ascending=[True, False], inplace=True)
    return df.iloc[0]

def mark_best_hit_based_on_rank(df):
    """Mark the best hit for each unique query_id based on score_rank."""
    best_hit_idx = df["score_rank"].idxmin()
    df.at[best_hit_idx, "best_hit"] = True
    return df

@click.command()
@click.option("--hits_csv", type=click.Path(exists=True), help="Path to the HMM search results CSV file.")
@click.option("--hmm_info_path", type=click.Path(exists=True), help="Path to the hmm_info_path file.")
@click.option("--gene_locs", type=click.Path(exists=True), help="Path to the gene locations TSV file.")
@click.option('--db_name', type=str, help='Name of the HMM database.')
@click.option("--output", type=click.Path(), help="Path to the formatted output file.")
def main(hits_csv, hmm_info_path, gene_locs, db_name, output):

    # Load HMM search results CSV file
    print("Loading HMM search results CSV file...")
    hits_df = pd.read_csv(hits_csv)

    # Load gene locations TSV file
    print("Loading gene locations TSV file...")
    gene_locs_df = pd.read_csv(gene_locs, sep='\t', usecols=['query_id', 'start_position', 'stop_position'])

    # Merge hits_df with gene_locs_df
    hits_df = pd.merge(hits_df, gene_locs_df, on='query_id', how='left')

    # Preprocess HMM search results
    print("Processing HMM search results...")
    hits_df['target_id'] = hits_df['target_id'].str.replace(r'.hmm', '', regex=True)
    hits_df['bitScore'] = hits_df.apply(calculate_bit_score, axis=1)
    hits_df['score_rank'] = hits_df.apply(calculate_rank, axis=1)
    hits_df.dropna(subset=['score_rank'], inplace=True)

    # Find the best hit for each unique query_id
    best_hits = hits_df.groupby('query_id').apply(find_best_hit).reset_index(drop=True)

    # Mark the best hit for each unique query_id based on score_rank
    best_hits = best_hits.groupby('query_id').apply(mark_best_hit_based_on_rank).reset_index(drop=True)

    # Load hmm_info_path file and check if it's not empty (dummy sheet handling)
    if hmm_info_path is not None and not (hmm_info_path_df := pd.read_csv(hmm_info_path, sep="\t", index_col=0)).empty:
        # Extract and format EC numbers from the "definition" column
        hmm_info_path_df[f'{db_name}_EC'] = hmm_info_path_df['definition'].apply(extract_ec_numbers)
        # Example of merging (assuming the rest of your script runs before this):
        merged_df = pd.merge(best_hits, hmm_info_path_df[['definition', f'{db_name}_EC']], how='left', left_on='target_id', right_index=True)
    else:
        merged_df = best_hits
        merged_df[f'{db_name}_EC'] = ''

    # Keep only the relevant columns in the final output, including '{db_name}_EC'
    final_output_df = merged_df[['query_id', 'start_position', 'stop_position', 'strandedness', 'target_id', 'score_rank', 'bitScore', 'definition', f'{db_name}_EC']]

    # Rename the columns for clarity
    final_output_df.columns = ['query_id', 'start_position', 'stop_position', 'strandedness', f'{db_name}_id', f'{db_name}_score_rank', f'{db_name}_bitScore', f'{db_name}_description', f'{db_name}_EC']

    # Save the modified DataFrame to CSV
    final_output_df.to_csv(output, index=False)

    print("Process completed successfully!")

if __name__ == "__main__":
    main()
