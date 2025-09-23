#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "" || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0") INPUT_GFF OUTPUT_GFF"
    exit 1
fi

INPUT_FILE=$1
OUTPUT_FILE=$2

awk 'BEGIN{FS=OFS="\t"}
/^#/ { print; next }

{
    seqid = $1
    attrs = $9

    # allow optional space after ; before ID=
    if (match(attrs, /(^|;[ ]*)ID=([^;]+)/)) {
        start = RSTART; len = RLENGTH
        idstr = substr(attrs, start, len)   # e.g., "; ID=1_12" or "ID=1_12"

        idval = idstr
        sub(/^[;][ ]*ID=/, "", idval)      # strip leading "; " if present
        sub(/^ID=/, "", idval)             # or bare "ID="

        n = split(idval, parts, "_")
        if (n >= 2) {
            new_id = seqid "_" parts[2]
            prefix = substr(attrs, 1, start-1)
            suffix = substr(attrs, start+len)

            lead = ""
            if (substr(idstr,1,1) == ";") {
                # preserve original spacing after ;
                m = match(idstr, /^;[ ]*/)
                lead = substr(idstr, 1, RLENGTH)
            }
            attrs = prefix lead "ID=" new_id suffix
            $9 = attrs
        }
    }
    print
}' "$INPUT_FILE" > "$OUTPUT_FILE"
