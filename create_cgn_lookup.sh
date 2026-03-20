#!/bin/bash

OUTPUT="/home/jmontero/selecting_accessions/filereports/ena_filereports.tsv"
TMP_CODES=$(mktemp)
TMP_LOOKUP=$(mktemp)

rm -f "${TMP_LOOKUP}" "${TMP_CODES}"

# Extract all CGN codes (LA followed by 4 digits) anywhere in the file
tail -n +2 "$OUTPUT" | grep -oP 'CGN\d{5}' | sort -u > "$TMP_CODES"

echo -e "cgn_code\tis_cgn\tcgn_url\tcgn_smta_needed" >> "${TMP_LOOKUP}"
while read -r CODE; do
    echo "reading $CODE"
    CGN_URL="https://cgngenis.wur.nl/accessiondetails/${CODE}"

    FIELDS=$(curl -fs "$CGN_URL" | sed -n '59,213p' | grep -A 3 "SMTA needed" | tail -n 1)
    IS_CGN="Yes"
    CGN_SMTA_NEEDED=$(if grep "Yes" $FIELDS ; then echo "Yes" ; else echo "No" fi)
    if [[ ! -n $FIELDS ]] ; then
        CGN_URL=""
        IS_CGN="No"
        CGN_SMTA_NEEDED=""
    fi
    echo -e "${CODE}\t${IS_CGN}\t${CGN_URL}\t${CGN_SMTA_NEEDED}" >> "${TMP_LOOKUP}"
done < "${TMP_CODES}"

mv "${TMP_LOOKUP}" /home/jmontero/selecting_accessions/filereports/CGN_lookup.tsv
