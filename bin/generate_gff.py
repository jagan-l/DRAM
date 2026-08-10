#!/usr/bin/env python3

import sys
import re
from pathlib import Path


def parse_prodigal_header(header):
    """
    Parse Prodigal FASTA headers like:
    >contig_1_1 # 3 # 281 # 1 # ID=1_1;partial=00;...
    """
    header = header.lstrip(">").strip()

    parts = [p.strip() for p in header.split("#")]
    if len(parts) < 5:
        raise ValueError(f"Header does not look like Prodigal output: {header}")

    gene_id = parts[0]
    start = int(parts[1])
    end = int(parts[2])
    strand_raw = parts[3]
    attrs_raw = parts[4]

    strand = "+" if strand_raw == "1" else "-"

    # Infer contig name by removing final _geneNumber if possible.
    # Example: contig_1_42 -> contig_1
    match = re.match(r"(.+)_\d+$", gene_id)
    seqid = match.group(1) if match else gene_id

    attrs = {}
    for item in attrs_raw.split(";"):
        if "=" in item:
            key, value = item.split("=", 1)
            attrs[key] = value

    attrs.setdefault("ID", gene_id)

    attr_string = ";".join(f"{k}={v}" for k, v in attrs.items())

    return seqid, start, end, strand, attr_string


def fasta_headers(path):
    with open(path) as handle:
        for line in handle:
            if line.startswith(">"):
                yield line.strip()


def main():
    if len(sys.argv) != 2:
        sys.exit(
            f"Usage: {Path(sys.argv[0]).name} prodigal_output.faa_or_fna > output.gff"
        )

    print("##gff-version 3")

    for header in fasta_headers(sys.argv[1]):
        seqid, start, end, strand, attrs = parse_prodigal_header(header)

        print(
            "\t".join(
                [
                    seqid,
                    "Prodigal",
                    "CDS",
                    str(start),
                    str(end),
                    ".",
                    strand,
                    "0",
                    attrs,
                ]
            )
        )


if __name__ == "__main__":
    main()
