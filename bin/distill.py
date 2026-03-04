#!/usr/bin/env python
"""This is the script that distills the genomes"""
import click
import os
from pathlib import Path
import polars as pl
from xlsxwriter import Workbook
from utils.logger import get_logger
from utils.click_utils import validate_comma_separated
from utils.click_utils import validate_comma_separated
from utils.excel import write_summarized_genomes_to_xlsx
from utils.pl_utils import read_csv
from rule_parser.src.rules import evaluate_rules_on_anno, ID_EXPR_DICT

logger = get_logger(filename=Path(__file__).stem)

COL_GENE_ID, COL_GENE_DESCRIPTION, COL_MODULE, COL_SHEET, COL_HEADER, COL_SUBHEADER, RULES_PARENT, RULES = 'gene_id', 'gene_description', 'pathway', 'topic_ecosystem','category', 'subcategory', 'parent', 'rules'
OPTIONAL_COLUMNS = [RULES_PARENT, RULES]
RRNA_COLUMNS = [COL_GENE_ID, COL_GENE_DESCRIPTION, COL_SHEET, COL_HEADER, COL_SUBHEADER]
TRNA_COLUMNS = RRNA_COLUMNS + ['AA_type']
CORE_COLUMNS = RRNA_COLUMNS + [COL_MODULE]
FRAME_COLUMNS = CORE_COLUMNS + OPTIONAL_COLUMNS
RRNA_TYPES = ['5S rRNA', '16S rRNA', '23S rRNA']
TAXONOMY_LEVELS = ['d', 'p', 'c', 'o', 'f', 'g', 's']
CONSTANT_DISTILLATE_COLUMNS = [COL_GENE_ID, COL_GENE_DESCRIPTION, COL_MODULE, COL_HEADER, COL_SUBHEADER]
DISTILATE_SORT_ORDER_COLUMNS = [COL_HEADER, COL_SUBHEADER, COL_MODULE, COL_GENE_ID]
EXCEL_MAX_CELL_SIZE = 32767

FASTA_COLUMN = os.getenv('FASTA_COLUMN', 'input_fasta')
DISTILL_DIR = Path(__file__).parent / "assets/forms/distill_sheets"

    
def check_columns(data, logger):
    functions = [i for i in ID_EXPR_DICT if i in data.columns]
    missing = [i for i in ID_EXPR_DICT if i not in data.columns]
    logger.info("Note: the following id fields "
          f"were not in the annotations file and are not being used: {missing},"
          f" but these are {functions}")  

def make_genome_summary(annotations, genome_summary_frame: pl.LazyFrame, logger, groupby_column=FASTA_COLUMN):
    rules_col = "rules"
    if rules_col not in genome_summary_frame.collect_schema().names():
        genome_summary_frame = genome_summary_frame.with_columns(
            pl.lit(None).cast(pl.String).alias(rules_col)
        )

    genome_summary_frame = genome_summary_frame.with_columns(
        pl.when(pl.col(rules_col).is_not_null())
        .then(pl.col(rules_col))
        .otherwise(pl.col("gene_id"))
        .alias(rules_col)
    )

    df = evaluate_rules_on_anno(
        rules=genome_summary_frame,
        # rules_tsv_path="/home/projects-wrighton-2/Pipeline_Development/DRAM2-Nextflow/DRAM/bin/assets/forms/distill_sheets/distill_metals.tsv",
        annotations=annotations,
        sample_col="query_id",
        label_col="gene_id",
        parent_col=None,
        rules_col=rules_col
        )
    df = df.join(annotations.select([pl.col("query_id"), pl.col("input_fasta")]), on="query_id").drop("query_id")
    df = df.group_by("input_fasta").agg(pl.exclude("input_fasta").sum())

    df = df.select(pl.exclude("input_fasta")).transpose(include_header=True, header_name="gene_id", column_names=df["input_fasta"])

    df = genome_summary_frame.collect().join(df, on="gene_id", how="left")

    df = df.drop(OPTIONAL_COLUMNS, strict=False)

    return df

# TODO: add assembly stats like N50, longest contig, total assembled length etc
def make_genome_stats(annotations: pl.DataFrame, rrna_frame: pl.DataFrame = None, trna_frame: pl.DataFrame = None, quast_frame: pl.DataFrame = None, groupby_column: str = FASTA_COLUMN):
    rows = list()
    columns = ['genome']
    if 'scaffold' in annotations.columns:
        columns.append('number of scaffolds')
    if 'bin_taxonomy' in annotations.columns:
        columns.append('taxonomy')
    if 'bin_completeness' in annotations.columns:
        columns.append('completeness score')
    if 'bin_contamination' in annotations.columns:
        columns.append('contamination score')
    for genome, frame in annotations.group_by(groupby_column):
        row = [genome[0]]
        if 'scaffold' in frame.columns:
            row.append(len(set(frame['scaffold'])))
        if 'bin_taxonomy' in frame.columns:
            row.append(frame['bin_taxonomy'][0])
        if 'bin_completeness' in frame.columns:
            row.append(frame['bin_completeness'][0])
        if 'bin_contamination' in frame.columns:
            row.append(frame['bin_contamination'][0])
        rows.append(row)
    genome_stats = pl.DataFrame(rows, schema=columns, orient='row')
    if rrna_frame is not None:
        # Identify the "sample" columns (everything that's not metadata)
        meta_cols = RRNA_COLUMNS
        sample_cols = [c for c in rrna_frame.columns if c not in meta_cols]

        # group_by gene_id, sum sample columns
        df_rrna = (
            rrna_frame
            .group_by("gene_id")
            .agg([pl.col(c).sum().alias(c) for c in sample_cols])
        )

        # transpose: rows -> genomes (samples), columns -> gene_id
        # This creates a "genome" column from original sample column names
        df_rrna = df_rrna.transpose(
            include_header=True,
            header_name="genome",      # new first column name
            column_names="gene_id",    # column headers come from gene_id values
        )

        genome_stats = genome_stats.join(df_rrna, on="genome", how="inner")
        assert genome_stats.shape[0] == df_rrna.shape[0], "genomes from annotation file don't map to rrna file"
    if trna_frame is not None:
        meta_cols = TRNA_COLUMNS

        sample_cols = [c for c in trna_frame.columns if c not in meta_cols]

        df_trna = (
            trna_frame
            .filter(~pl.col("AA_type").is_in(["Undet", "Sup"]))
            .group_by("AA_type")
            .agg([pl.col(c).sum().alias(c) for c in sample_cols])
            .select([(pl.col(c) != 0).cast(pl.Int64).sum().alias(c) for c in sample_cols])
            .transpose(include_header=True, header_name="genome", column_names=["tRNA count"])
        )
        genome_stats = genome_stats.join(df_trna, on="genome", how="inner")
        
    if quast_frame is not None:
        quast_frame = (
            quast_frame
            .rename({groupby_column: "genome"})
            .drop("no. contigs")
        )

        genome_stats = genome_stats.join(quast_frame, on="genome", how="inner")
        assert genome_stats.shape[0] == quast_frame.shape[0], "genomes from annotation file don't map to quast file"

    return genome_stats


@click.command()
@click.option("-i", "--input_file", required=True, help="Annotations path")
# @click.option("-o", "--output_dir", required=True, help="Directory to write summarized genomes")
@click.option("--rrna_path", help="rRNA output from annotation")
@click.option("--trna_path", help="tRNA output from annotation")
@click.option("--quast_path", help="Quast summary TSV from the quast step")
@click.option("--groupby_column", help="Column from annotations to group as organism units",
                            default=FASTA_COLUMN)
@click.option("--distil_topics", default="default", help="Default distillates topics to run.")
@click.option("--distil_ecosystem", default="eng_sys,ag", help="Default distillates ecosystems to run.")
@click.option("--custom_distillate", default=[], callback=validate_comma_separated, help="Custom distillate forms to add your own modules, comma separated. ")
def distill(input_file, rrna_path=None, trna_path=None, quast_path=None, groupby_column=FASTA_COLUMN, distil_topics=None, distil_ecosystem=None,
                      custom_distillate=None):
    """Summarize metabolic content of annotated genomes"""

    # read in data
    try:
        annotations = pl.read_csv(input_file, separator="\t", infer_schema_length=10_000)
    except Exception as e:
        annotations = pl.read_csv(input_file, separator="\t", infer_schema_length=None)
    if 'bin_taxnomy' in annotations:
        annotations = annotations.sort_values('bin_taxonomy')

    # Check the columns are present
    check_columns(annotations, logger)

    trna_frame = read_csv(trna_path)
    rrna_frame = read_csv(rrna_path)
    quast_frame = read_csv(quast_path)

    distil_sheets_names = []
    if "default" in distil_topics:
        distil_sheets_names = [
            DISTILL_DIR / "distill_carbon.tsv",
            DISTILL_DIR / "distill_energy.tsv",
            DISTILL_DIR / "distill_misc.tsv",
            DISTILL_DIR / "distill_nitrogen.tsv",
            DISTILL_DIR / "distill_transport.tsv",
            DISTILL_DIR / "distill_metals.tsv"
        ]
    else:
        if 'carbon' in distil_topics:
            distil_sheets_names.append(DISTILL_DIR / "distill_carbon.tsv")
        if 'energy' in distil_topics:
            distil_sheets_names.append(DISTILL_DIR / "distill_energy.tsv")
        if 'misc' in distil_topics:
            distil_sheets_names.append(DISTILL_DIR / "distill_misc.tsv")
        if 'nitrogen' in distil_topics:
            distil_sheets_names.append(DISTILL_DIR / "distill_nitrogen.tsv")
        if 'transport' in distil_topics:
            distil_sheets_names.append(DISTILL_DIR / "distill_transport.tsv")
        if "metals" in distil_topics:
            distil_sheets_names.append(DISTILL_DIR / "distill_metals.tsv")
    
        
    if "ag" in distil_ecosystem:
        distil_sheets_names.append(DISTILL_DIR / "distill_ag.tsv")
    if "eng_sys" in distil_ecosystem:
        distil_sheets_names.append(DISTILL_DIR / "distill_eng_sys.tsv")
    
    if "camper_id" in annotations and ("default" in distil_topics or "camper" in distil_topics):
        distil_sheets_names.append(DISTILL_DIR / "distill_camper.tsv")
        
    logger.info(f"Distillate dir: {DISTILL_DIR}")
    logger.info(f"Distillate sheets to be used: {distil_sheets_names}")
    if custom_distillate:
        for custom_sheet in custom_distillate:
            distil_sheets_names.append(custom_sheet)
    
    genome_summary_form = pl.concat(
        [
            pl.scan_csv(s, separator="\t")
            .select([c for c in FRAME_COLUMNS if c in pl.scan_csv(s, separator="\t", n_rows=0).columns])
            for s in distil_sheets_names
        ],
        how="diagonal",
    )
    
    logger.info('Retrieved distillate genome summary form')

    # make genome stats
    genome_stats = make_genome_stats(annotations, rrna_frame, trna_frame, quast_frame=quast_frame, groupby_column=groupby_column)
    genome_stats.write_csv('genome_stats.tsv', separator='\t')
    logger.info('Calculated genome statistics')

    # make genome metabolism summary
    genome_summary = 'metabolism_summary.xlsx'
    logger.info(f'Giving counts for genome metabolism summary')
    summarized_genomes = make_genome_summary(annotations, genome_summary_form, logger, groupby_column)
    summarized_genomes.write_csv('summarized_genomes.tsv', separator='\t')
    kw = {"extra_frames": []}
    if rrna_frame is not None:
        kw["extra_frames"].append(rrna_frame)
    if trna_frame is not None:
        kw["extra_frames"].append(trna_frame)
    write_summarized_genomes_to_xlsx(
        df=summarized_genomes,
        output_file=genome_summary,
        group_by=COL_SHEET,
        sort_order_columns=DISTILATE_SORT_ORDER_COLUMNS,
        **kw
    )
    logger.info('Generated genome metabolism summary')

    
if __name__ == "__main__":
    distill()
