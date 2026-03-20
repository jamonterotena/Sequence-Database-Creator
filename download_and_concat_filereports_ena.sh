#!/bin/bash
#---------------------------------------------------------------------------------------------------------#
# Script: Downloads and concatenates ENA filereport from all study accessions in study_accession_list.txt
#---------------------------------------------------------------------------------------------------------#

DIR=/home/jmontero/selecting_accessions/filereports
INPUT=${DIR}/study_accession_list.txt
OUTPUT=${DIR}/ena_filereports.tsv
TMP_TABLE=$(mktemp)
TMP_OUTPUT=$(mktemp)

# Remove previous output to avoid duplicates
rm -f "$OUTPUT"

# Step 1: Download filereports and concatenate
while read -r STUDY_ACCESSION; do
    echo "Downloading filereport for $STUDY_ACCESSION..."

    URL="https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${STUDY_ACCESSION}&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,submission_accession,tax_id,scientific_name,instrument_platform,instrument_model,library_name,nominal_length,library_layout,library_strategy,library_source,library_selection,read_count,base_count,center_name,first_public,last_updated,experiment_title,study_title,study_alias,experiment_alias,run_alias,fastq_bytes,fastq_md5,fastq_ftp,fastq_aspera,fastq_galaxy,submitted_bytes,submitted_md5,submitted_ftp,submitted_aspera,submitted_galaxy,submitted_format,sra_bytes,sra_md5,sra_ftp,sra_aspera,sra_galaxy,sample_alias,broker_name,sample_title,nominal_sdev,first_created,bam_ftp,bam_bytes,bam_md5,fastq_file_role,submitted_file_role,sra_file_role,bam_file_role&format=tsv&download=true&limit=0"

    if wget -qO- "$URL" > "$TMP_TABLE"; then
        HEADER=$(head -n1 "$TMP_TABLE")
        DATA=$(tail -n +2 "$TMP_TABLE")

        # Create output with header if missing
        if [ ! -f "$OUTPUT" ]; then
            echo "$HEADER" > "$TMP_OUTPUT"
        fi
        echo "$DATA" >> "$TMP_OUTPUT"
    else
        echo "Skipping $STUDY_ACCESSION (URL not reachable)"
    fi
done < "$INPUT"
grep -v "^$" "${TMP_OUTPUT}" >  "$OUTPUT" # Remove empty lines
