#!/bin/bash
#-----------------------------------------------------------------------#
# Script: read length enrichment for filereports.tsv
# - Handles previously enriched files
# - Aligns new rows correctly
# - Search criteria: Case insensitivity, partial match, only genomic data
#-----------------------------------------------------------------------#

DIR="$(dirname "$0")/.."
#"/home/jmontero/selecting_accessions/filereports"
OUTPUT="${DIR}/filereports.tsv"
LOOKUP="${DIR}/instrument_lookup.tsv"
TMP_INDEX=$(mktemp)

echo ""
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo "  ~ ENRICHING WITH READ LENGTH DATA ~ "
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo ""

awk -F'\t' -v OFS='\t' -v lookup="$LOOKUP" '

BEGIN {
    # ---- Load lookup table ----
    while((getline line < lookup) > 0){
        if(line ~ /^read_length/) continue

        n = split(tolower(line), f, "\t")
        read_len = f[1]
        tech = f[2]
        model = f[3]

        key = tech " " model
        lookup_read[key] = read_len
        lookup_keys[++k] = key
    }
    close(lookup)
}

NR==1 {
    # ---- Detect columns ----
    for(i=1;i<=NF;i++){
        col = tolower($i)
        if(col=="instrument_platform") ip=i
        if(col=="library_strategy") ls=i
    }

    if(!ip || !ls){
        print "ERROR: Required columns not found" > "/dev/stderr"
        exit 1
    }

    print $0, "read_length"
    next
}

{
    platform = tolower($ip)
    strategy = tolower($ls)

    read="not_genomic"

    # ---- Only genomic entries ----
    if(strategy ~ /(wgs|genomic|dna)/){

        # ---- Try to match lookup ----
        for(i=1;i<=k;i++){
            key = lookup_keys[i]

            if(index(platform, key)){
                read = lookup_read[key]
                break
            }
        }

        # ---- fallback: technology-only match ----
        if(read=="not_genomic"){
            if(platform ~ /illumina|dnbseq|mgiseq|bgi/) read="short"
            else if(platform ~ /pacbio|nanopore|ont|oxford/) read="long"
        }
    }

    print $0, read
}
' "$OUTPUT" > "$TMP_INDEX"

# overwrite safely
mv "$TMP_INDEX" "$OUTPUT"

#--------------------------------------------------------------#
# Cleanup
#--------------------------------------------------------------#
rm -f "$TMP_INDEX"

echo "read length enrichment complete: $OUTPUT"
