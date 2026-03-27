#!/bin/bash
#-----------------------------------------------------------------------------------------------------------------------------#
# Creates lookup table for the TGRC accessions in ena_filereports.tsv
# The output of this script will be later used to incorporate information about the TGRC resources available to the filereport
#-----------------------------------------------------------------------------------------------------------------------------#

DIR="$(dirname "$0")/.."
#/home/jmontero/selecting_accessions/filereports
OUTPUT="${DIR}/filereports.tsv"
LOOKUP="${DIR}/CGN_lookup.tsv"
TMP_CODES=$(mktemp)
TMP_LOOKUP=$(mktemp)

echo ""
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "  ~ CREATING CGN LOOKUP TABLE ~"
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""

# Clean temp files
rm -f "$TMP_LOOKUP" "$TMP_CODES"

# Extract all CGN codes (CGN followed by 5 digits) anywhere in the file
tail -n +2 "$OUTPUT" | grep -oP 'CGN\d{5}' | sort -u > "$TMP_CODES"

# Read existing codes if lookup exists
EXISTING_CODES=""
if [ -f "$LOOKUP" ]; then
    EXISTING_CODES=$(tail -n +2 "$LOOKUP" | cut -f1 | sort -u)
fi

# Filter only new codes
NEW_CODES=$(comm -23 <(sort "$TMP_CODES") <(echo "$EXISTING_CODES" | sort))

# Header for temp lookup
echo -e "cgn_code\tcgn_available\tcgn_url\tcgn_smta_needed" > "$TMP_LOOKUP"

# Process each new code
while read -r CODE; do
    [ -z "$CODE" ] && continue
    echo "Processing $CODE..."
    CGN_URL="https://cgngenis.wur.nl/accessiondetails/${CODE}"

    # Grab the line containing "SMTA needed"
    FIELDS=$(curl -fs "$CGN_URL" | grep -A3 "SMTA needed" | tail -n1)
    
    cgn_available="Yes"
    if [ -z "$FIELDS" ]; then
        cgn_available="No"
        CGN_URL=""
        CGN_SMTA_NEEDED=""
        echo "	NO CGN entry found for $CODE"
    else
        echo "	CGN entry found for $CODE"
        # Check if the line contains "Yes"
        if echo "$FIELDS" | grep -q "Yes"; then
            CGN_SMTA_NEEDED="Yes"
        else
            CGN_SMTA_NEEDED="No"
        fi
    fi

    echo -e "${CODE}\t${cgn_available}\t${CGN_URL}\t${CGN_SMTA_NEEDED}" >> "$TMP_LOOKUP"
done <<< "$NEW_CODES"

# Append new results to existing file, or move temp if it does not exist
if [ -f "$LOOKUP" ]; then
    tail -n +2 "$TMP_LOOKUP" >> "$LOOKUP"
else
    mv "$TMP_LOOKUP" "$LOOKUP"
fi

# Clean up
rm -f "$TMP_CODES" "$TMP_LOOKUP"

echo "Done CREATING cgn LOOKUP TABLE.  Output: $LOOKUP"
