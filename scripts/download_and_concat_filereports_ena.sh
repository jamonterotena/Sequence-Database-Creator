#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------#
# Append ENA filereports of study_accessions
# Simply write the study accessions you want to add the ENA filereport for in a file named study_accession_lists.txt
# This script will create a filereport for all the accessions by rows, with all the columns - Or append the new accessions to previous files
#-------------------------------------------------------------------------------------------------------------------------------------------#

set -euo pipefail

DIR="$(dirname "$0")/.."
#/home/jmontero/selecting_accessions/filereports
INPUT=${DIR}/study_accession_list.txt
OUTPUT=${DIR}/ena_filereports.tsv
TMP_TABLE=$(mktemp)

echo ""
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo "  ~ DOWNLOADING ENA METADATA ~ "
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo ""

cut -d ' ' -f 1 "$INPUT" | sort -u | while read -r STUDY_ACCESSION; do
    echo "Downloading filereport for $STUDY_ACCESSION..."

    URL="https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${STUDY_ACCESSION}&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,submission_accession,tax_id,scientific_name,instrument_platform,instrument_model,library_name,nominal_length,library_layout,library_strategy,library_source,library_selection,read_count,base_count,center_name,first_public,last_updated,experiment_title,study_title,study_alias,experiment_alias,run_alias,fastq_bytes,fastq_md5,fastq_ftp,fastq_aspera,fastq_galaxy,submitted_bytes,submitted_md5,submitted_ftp,submitted_aspera,submitted_galaxy,submitted_format,sra_bytes,sra_md5,sra_ftp,sra_aspera,sra_galaxy,sample_alias,broker_name,sample_title,nominal_sdev,first_created,bam_ftp,bam_bytes,bam_md5,fastq_file_role,submitted_file_role,sra_file_role,bam_file_role&format=tsv&download=true&limit=0"

    if wget -qO- "$URL" > "$TMP_TABLE"; then
        HEADER=$(head -n1 "$TMP_TABLE")
        DATA=$(tail -n +2 "$TMP_TABLE")

        if [ ! -f "$OUTPUT" ]; then
            # Case 1: file does not exist
            echo "$HEADER" > "$OUTPUT"
            echo "$DATA" >> "$OUTPUT"

        else
            # Check if header exists in OUTPUT
            if head -n1 "$OUTPUT" | grep -q "study_accession"; then
                # Case 2: header already present → append only data
                echo "$DATA" >> "$OUTPUT"
            else
                # Case 3: file exists but no header → prepend header
                TMP_FIX=$(mktemp)
                {
                    echo "$HEADER"
                    cat "$OUTPUT"
                } > "$TMP_FIX" && mv "$TMP_FIX" "$OUTPUT"

                echo "$DATA" >> "$OUTPUT"
            fi
        fi
    else
        echo "Skipping $STUDY_ACCESSION (URL not reachable)"
    fi

done

# Remove empty lines (optional but safe)
grep -v '^[[:space:]]*$' "$OUTPUT" > "${OUTPUT}.clean" && mv "${OUTPUT}.clean" "$OUTPUT"

# Add column with source (SRA)
paste -d '\t' \
  "$OUTPUT" \
  <(awk 'NR==1{print "source"} NR>1{print "ENA"}' "$OUTPUT") \
  > "${OUTPUT}.tmp" && mv "${OUTPUT}.tmp" "$OUTPUT"

rm "$TMP_TABLE"

echo "Done. Output: $OUTPUT"
