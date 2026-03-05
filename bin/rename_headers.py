#!/usr/bin/env python
import sys

input_faa = sys.argv[1]
output_faa = sys.argv[2]
prefix = sys.argv[3]

with open(input_faa) as fin, open(output_faa, "w") as fout:
    for line in fin:
        if line.startswith(">"):
            fout.write(f">{prefix}_{line[1:]}")
        else:
            fout.write(line)
