from typing import Iterable, TypeAlias

import polars as pl
from xlsxwriter import Workbook
import os


Columns: TypeAlias = str | Iterable[str]
PathLike: TypeAlias = str | os.PathLike


def write_summarized_genomes_to_xlsx(
    df: pl.DataFrame,
    output_file: PathLike,
    group_by: Columns,
    sort_order_columns: Columns,
    extra_frames=tuple(),
):
    # turn all this into an xlsx
    with Workbook(output_file) as wb:
        for sheet, frame in df.group_by(group_by):
            frame = frame.sort(sort_order_columns)
            frame = frame.drop(group_by)
            frame.write_excel(
                workbook=wb,
                worksheet=sheet[0],
            )
        for extra_frame in extra_frames:
            if extra_frame is not None and not extra_frame.is_empty():
                extra_frame.write_excel(
                    workbook=wb,
                    worksheet=str(extra_frame[group_by][0]),
                )
