#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------#
# Creates lookup table for the publications (study accessions) in ena_filereports.tsv
# Takes 3 best matches per study accession
# The output of this script will be later used to incorporate information about the papers under the study accessions listed in filereport
#-------------------------------------------------------------------------------------------------------------------------------------------#

DIR="$(dirname "$0")/.."
#/home/jmontero/selecting_accessions/filereports
INPUT=${DIR}/study_accession_list.txt
OUTPUT=${DIR}/publication_lookup.tsv
TMP_HTML=$(mktemp)

echo "Step 1: Importing filereports..."

cat "${INPUT}" | cut -d " " -f 1 | sort -u | while read -r STUDY_ACCESSION; do
    echo "Processing $STUDY_ACCESSION..." >&2

    URL="https://pmc.ncbi.nlm.nih.gov/search/?term=${STUDY_ACCESSION}"

    # ---- Download once (silent) ----
    CONTENT=$(wget -qO- "$URL" 2>/dev/null)

    # Skip if empty
    [[ -z "$CONTENT" ]] && continue

    # ---- Extract relevant block ----
    echo "$CONTENT" | grep -A 3 -B 3 result_click > "$TMP_HTML" 2>/dev/null

    # Skip if no matches
    [[ ! -s "$TMP_HTML" ]] && continue

    DATA=$(cat "$TMP_HTML")

    PUB_PMC=$(echo "$DATA" | grep -oP "PMC\d+" | sort -u | head -n 3 | tr "\n" ";" | sed "s/;$//")
    PUB_TITLE=$(echo "$DATA" | grep -A 1 "label=" | grep -v label | grep -v "\-\-" | sed 's/^[[:space:]]*//' | head -n 3 | tr "\n" ";" | sed "s/;$//")
    PUB_URL=$(echo "$DATA" | grep href | cut -d '"' -f 2 | sort -u | head -n 3 | tr "\n" ";" | sed "s/;$//")

    # ---- Header setup (simple + robust) ----
    if [[ ! -f "$OUTPUT" ]]; then
        echo -e "study_accession\tpmc_code\tpublication_title\tpublication_url" > "$OUTPUT"
    elif ! head -n1 "$OUTPUT" | grep -q "study_accession"; then
        TMP_FIX=$(mktemp)
        {
            echo -e "study_accession\tpmc_code\tpublication_title\tpublication_url"
            cat "$OUTPUT"
        } > "$TMP_FIX" && mv "$TMP_FIX" "$OUTPUT"
    fi

    # ---- Append data ----
    echo -e "${STUDY_ACCESSION}\t${PUB_PMC}\t${PUB_TITLE}\t${PUB_URL}" >> "$OUTPUT"

done

# Remove empty lines (optional but safe)
grep -v "^$" "$OUTPUT" > "${OUTPUT}.clean" && mv "${OUTPUT}.clean" "$OUTPUT"

rm "$TMP_HTML"

echo "Done. Output: $OUTPUT"
