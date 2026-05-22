#!/usr/bin/env python
import sys
from pathlib import Path

input_f = sys.argv[1]
output_dir = sys.argv[2]
prefix = sys.argv[3]

with (
    open(input_f) as fin,
    open(Path(output_dir) / f"{prefix}{Path(input_f).suffix}", "w") as fout,
):
    for line in fin:
        if line.startswith(">"):
            fout.write(f">{prefix}_{line[1:]}")
        else:
            fout.write(line)
