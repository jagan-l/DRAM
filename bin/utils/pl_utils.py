import polars as pl

def read_csv(path, check_for_null_file=True, seperator="\t", *args, **kwargs) -> pl.DataFrame | None:
    if path is None:
        return None
    df = pl.read_csv(path, separator=seperator, *args, **kwargs)
    if check_for_null_file:
        if df.columns == ["NULL"]:
            return None
        if df.is_empty():
            return None
    return df
    