#!/bin/bash

OUTPUT="/home/jmontero/selecting_accessions/filereports/ena_filereports.tsv"
TMP_CODES=$(mktemp)
TMP_LOOKUP=$(mktemp)

rm -f "${TMP_LOOKUP}" "${TMP_CODES}"

# Extract all TGRC codes (LA followed by 4 digits) anywhere in the file
tail -n +2 "$OUTPUT" | grep -oP 'LA\d{4}' | sort -u > "$TMP_CODES"

echo -e "tgrc_code\tis_tgrc\ttgrc_url\ttgrc_status\ttgrc_shipment_possible" >> "${TMP_LOOKUP}"
while read -r CODE; do
    echo "reading $CODE"
    TGRC_URL="https://tgrc-mvc.plantsciences.ucdavis.edu/Accession/detail/${CODE}"

    FIELDS=$(curl -fs "$TGRC_URL" | sed -n '59,213p' | grep "input" | head -n 3 | grep -oP 'value="\K[^"]+')
    IS_TGRC="Yes"
    TGRC_STATUS=$(echo $FIELDS | cut -d ' ' -f 2)
    TGRC_SHIPMENT_POSSIBLE=$(echo $FIELDS | cut -d ' ' -f 3)
    if [[ ! -n $FIELDS ]] ; then
        IS_TGRC="No"
        TGRC_URL=""
    fi
    echo -e "${CODE}\t${IS_TGRC}\t${TGRC_URL}\t${TGRC_STATUS}\t${TGRC_SHIPMENT_POSSIBLE}" >> "${TMP_LOOKUP}"
done < "${TMP_CODES}"

mv "${TMP_LOOKUP}" /home/jmontero/selecting_accessions/filereports/TGRC_lookup.tsv
