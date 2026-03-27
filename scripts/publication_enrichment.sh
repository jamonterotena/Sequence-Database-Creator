#!/bin/bash
#--------------------------------------------------------------#
# Script: publication enrichment for filereports.tsv
# - Handles previously enriched files
# - Aligns new rows correctly
#--------------------------------------------------------------#

DIR="$(dirname "$0")/.."
#"/home/jmontero/selecting_accessions/filereports"
OUTPUT="${DIR}/filereports.tsv"
LOOKUP="${DIR}/publication_lookup.tsv"
TMP_INDEX=$(mktemp)

echo ""
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo "  ~ ENRICHING WITH PUBLICATION DATA ~ "
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo ""

#--------------------------------------------------------------#
# Step 0: Truncate all rows to original filereport width
#--------------------------------------------------------------#

# Take the last row (assumed to be newly appended, not enriched yet)
LAST_ROW=$(tail -n1 "$OUTPUT")
ORIG_COLS=$(echo "$LAST_ROW" | awk -F'\t' '{print NF}')

# Truncate all rows to original column count
awk -v cols="$ORIG_COLS" -F'\t' '{
    for(i=1;i<=cols;i++){
        printf "%s", $i
        if(i<cols) printf "\t"
    }
    printf "\n"
}' "$OUTPUT" > "${OUTPUT}.trunc"
mv "${OUTPUT}.trunc" "$OUTPUT"

#--------------------------------------------------------------#
# Step 1: LEFT JOIN with study accession
#--------------------------------------------------------------#
${DIR}/scripts/merge_tables.R \
left \
"${OUTPUT}" "${LOOKUP}" \
"${OUTPUT}.tmp" \
study_accession

mv "${OUTPUT}.tmp" "${OUTPUT}"

#--------------------------------------------------------------#
# Cleanup
#--------------------------------------------------------------#
rm -f "$TMP_INDEX"

echo "publication enrichment complete: $OUTPUT"
