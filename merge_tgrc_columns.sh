#!/bin/bash

DIR="/home/jmontero/selecting_accessions/filereports"
OUTPUT="${DIR}/ena_filereports.tsv"
LOOKUP="${DIR}/TGRC_lookup.tsv"
TMP_INDEX=$(mktemp)

echo -e "tgrc_code" > "$TMP_INDEX"

# Build TGRC index (aligned with OUTPUT)
tail -n +2 "$OUTPUT" | while read -r line; do
    match=$(echo "$line" | grep -oP 'LA\d{4}' | tail -n1)
    echo "${match:-}"
done >> "$TMP_INDEX"

# Merge OUTPUT + TGRC codes
paste --delimiter=$'\t' "$OUTPUT" "$TMP_INDEX" > "${OUTPUT}.tmp"

#--------------------------------------------------------------#
# LEFT JOIN with lookup
#--------------------------------------------------------------#
awk -F'\t' '
BEGIN{OFS="\t"}

# Load lookup table
NR==FNR {
    if (FNR==1) next
    lookup[$1]=$0
    next
}

# Process merged file
FNR==1 {
    print $0, "is_tgrc", "tgrc_url", "tgrc_status", "tgrc_shipment_possible"
    next
}

{
    code = $NF   # last column = tgrc_code

    if (code != "" && code in lookup) {
        split(lookup[code], arr, "\t")
        print $0, arr[2], arr[3], arr[4], arr[5]
    } else {
        print $0, "No", "", "", ""
    }
}
' "$LOOKUP" "${OUTPUT}.tmp" | sponge "${OUTPUT}"

rm -f "${OUTPUT}.tmp" "$TMP_INDEX"
