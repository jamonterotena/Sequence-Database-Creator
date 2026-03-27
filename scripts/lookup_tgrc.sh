#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------------------#
# Creates lookup table for the TGRC accessions in ena_filereports.tsv
# The output of this script will be later used to incorporate information about the TGRC resources available to the filereport
#-----------------------------------------------------------------------------------------------------------------------------#

DIR="$(dirname "$0")/.."
#/home/jmontero/selecting_accessions/filereports
OUTPUT="${DIR}/filereports.tsv"
LOOKUP="${DIR}/TGRC_lookup.tsv"
TMP_CODES=$(mktemp)
TMP_LOOKUP=$(mktemp)

echo ""
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo "  ~ CREATING TGRC LOOKUP TABLE ~ "
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo ""

# Extract all TGRC codes (LA followed by 4 digits) anywhere in the file
tail -n +2 "$OUTPUT" | grep -oP 'LA\d{4}' | sort -u > "$TMP_CODES"

# Check if lookup already exists
EXISTING_CODES=""
if [ -f "$LOOKUP" ]; then
    # skip header, take first column
    EXISTING_CODES=$(tail -n +2 "$LOOKUP" | cut -f 1 | sort -u)
fi

# Prepare temp lookup file with header
echo -e "tgrc_code\ttgrc_available\ttgrc_url\ttgrc_status\ttgrc_shipment_possible\tcollection_number" > "$TMP_LOOKUP"

# Filter out codes already in existing lookup
NEW_CODES=$(comm -23 <(sort "$TMP_CODES") <(echo "$EXISTING_CODES" | sort))

# Loop only over new codes
while read -r CODE; do
    [ -z "$CODE" ] && continue

    echo "Processing $CODE TGRC data..."
    TGRC_URL="https://tgrc-mvc.plantsciences.ucdavis.edu/Accession/detail/${CODE}"

    FIELDS=$(curl -fs "$TGRC_URL" \
        | sed -n '59,213p' \
        | grep "input\|accession.CollectionNum" \
        | head -n 4 \
        | grep -oP 'value="\K[^"]+' \
        | tr "\n" "\t")

    if [[ -z "$FIELDS" ]]; then
        tgrc_available="No"
        TGRC_URL=""
        TGRC_STATUS=""
        TGRC_SHIPMENT_POSSIBLE=""
        COLLECTION_NUMBER=""

        echo "  NO TGRC entry found for $CODE"
    else
        tgrc_available="Yes"

        TGRC_STATUS=$(printf "%s" "$FIELDS" | cut -f2)
        TGRC_SHIPMENT_POSSIBLE=$(printf "%s" "$FIELDS" | cut -f3)

        COLLECTION_NUMBER=$(printf "%s\n" "$FIELDS" \
            | tail -n 1 \
            | grep -oP 'value="\K[^"]+')

        echo "  TGRC entry found for $CODE"
    fi

    echo -e "${CODE}\t${tgrc_available}\t${TGRC_URL}\t${TGRC_STATUS}\t${TGRC_SHIPMENT_POSSIBLE}\t${COLLECTION_NUMBER}" >> "$TMP_LOOKUP"

done <<< "$NEW_CODES"

# Append new results to existing file (if any)
if [ -f "$LOOKUP" ]; then
    tail -n +2 "$TMP_LOOKUP" >> "$LOOKUP"
else
    mv "$TMP_LOOKUP" "$LOOKUP"
fi

# Clean up
rm -f "$TMP_CODES" "$TMP_LOOKUP"

echo "Done creating TGRC lookup table. Output: $LOOKUP"
