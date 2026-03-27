#!/bin/bash
#--------------------------------------------------------------#
# Script: TGRC enrichment for filereports.tsv
# - Handles previously enriched files
# - Aligns new rows correctly
#--------------------------------------------------------------#

DIR="$(dirname "$0")/.."
#"/home/jmontero/selecting_accessions/filereports"
OUTPUT="${DIR}/filereports.tsv"
LOOKUP="${DIR}/TGRC_lookup.tsv"
TMP_INDEX=$(mktemp)

echo ""
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo "  ~ ENRICHING WITH TGRC DATA ~ "
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
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
# Step 1: Build TGRC code index aligned with filereport
#--------------------------------------------------------------#
echo -e "tgrc_code" > "$TMP_INDEX"

# Extract last TGRC code in each row (if any)
tail -n +2 "$OUTPUT" | while read -r line; do
    match=$(echo "$line" | grep -oP 'LA\d{4}' | tail -n1)
    echo "${match:-}"
done >> "$TMP_INDEX"

# Merge filereport + TGRC code
paste --delimiter=$'\t' "$OUTPUT" "$TMP_INDEX" > "${OUTPUT}.tmp"

#--------------------------------------------------------------#
# Step 2: LEFT JOIN with TGRC lookup
#--------------------------------------------------------------#
${DIR}/scripts/merge_tables.R \
left \
"${OUTPUT}.tmp" "${LOOKUP}" \
"${OUTPUT}" \
tgrc_code

# Fill up empty tgrc_available values to clearly differentiate between LA accessions not available in TGRC and non-LA accessions
awk -F'\t' 'BEGIN{OFS="\t"}
NR==1{
  for(i=1;i<=NF;i++) if($i=="tgrc_available") col=i
}
NR>1 && $col==""{$col=""}
{print}
' "${OUTPUT}" > "${OUTPUT}.tmp" && mv "${OUTPUT}.tmp" "${OUTPUT}"

#--------------------------------------------------------------#
# Cleanup
#--------------------------------------------------------------#
rm -f "${OUTPUT}.tmp" "$TMP_INDEX"

echo "TGRC enrichment complete: $OUTPUT"
