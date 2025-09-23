#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE=$1
OUTPUT_FILE=$2

awk -F'\t' '
BEGIN {
    OFS = "\t";
    print "query_id","start_position","stop_position","strandedness","gene_number"
}
# skip comments; keep CDS only
$0 !~ /^#/ && $3=="CDS" {
    cnt[$1]++;                          # per-sequence gene counter
    strand = ($7=="+") ? 1 : -1;        # map strand to {+1,-1}
    printf "%s_%d\t%d\t%d\t%d\t%d\n", $1, cnt[$1], $4, $5, strand, cnt[$1]
}' "$INPUT_FILE" > "$OUTPUT_FILE"