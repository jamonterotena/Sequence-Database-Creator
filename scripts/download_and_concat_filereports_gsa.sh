#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------#
# Download GSA filereports of study_accessions
# Simply write the study accessions you want to add the filereport for in a file named study_accession_lists.txt
# This script will create a filereport for all the accessions by rows, with all the columns - Or append the new accessions to previous files
#-------------------------------------------------------------------------------------------------------------------------------------------#

set -euo pipefail

DIR="$(dirname "$0")/.."
#/home/jmontero/selecting_accessions/filereports
INPUT=${DIR}/study_accession_list.txt
ENA_OUTPUT=${DIR}/ena_filereport.tsv
GSA_OUTPUT_CSV=${DIR}/gsa_filereports.csv
GSA_OUTPUT_TSV=${DIR}/gsa_filereports.tsv
TMP_SAMPLE=$(mktemp)
TMP_EXPERIMENT=$(mktemp)
TMP_RUN=$(mktemp)
TMP_OUTPUT=$(mktemp)

echo ""
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo "  ~ DOWNLOADING GSA METADATA ~ "
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo ""

source activate random_tools

# -----------------------------
# Step 1: Fetch GSA metadata
# -----------------------------
cut -d ' ' -f 1 "$INPUT" | sort -u | while read -r STUDY_ACCESSION; do
  if ! grep -qw "${STUDY_ACCESSION}" "${ENA_OUTPUT}" 2>/dev/null && \
    ACCESSION_CODE=$(curl -fs "https://ngdc.cncb.ac.cn/bioproject/browse/${STUDY_ACCESSION}" \
      | grep gsa \
      | grep -E "CRA|CRX|SRR" \
      | grep -oP '(CRA\d+|CRX\d+|SRR\d+)' \
      | head -n 1) && \
    [ -n "$ACCESSION_CODE" ]; then

    echo "Downloading filereport for $STUDY_ACCESSION..."

    wget \
      -q \
      --method=POST \
      --header="User-Agent: Mozilla/5.0" \
      --header="Referer: https://ngdc.cncb.ac.cn/gsa/browse/${ACCESSION_CODE}" \
      --header="Content-Type: application/x-www-form-urlencoded" \
      --body-data="type=3&dlAcession=${ACCESSION_CODE}" \
      https://ngdc.cncb.ac.cn/gsa/file/exportExcelFile \
      -O "${DIR}/${ACCESSION_CODE}.xlsx"

    xlsx2csv -n Sample "${DIR}/${ACCESSION_CODE}.xlsx" > ${TMP_SAMPLE}
    xlsx2csv -n Experiment "${DIR}/${ACCESSION_CODE}.xlsx" > ${TMP_EXPERIMENT}
    xlsx2csv -n Run "${DIR}/${ACCESSION_CODE}.xlsx" > ${TMP_RUN}

    csvtk join --left-join --fields "5;2" ${TMP_RUN} \
      <(csvtk join --left-join --fields "6;3" ${TMP_EXPERIMENT} ${TMP_SAMPLE}) \
      > ${TMP_OUTPUT}

    # Append or initialize master CSV
    if [ ! -s "$GSA_OUTPUT_CSV" ]; then
      cat "$TMP_OUTPUT" > "$GSA_OUTPUT_CSV"
    else
      tail -n +2 "$TMP_OUTPUT" >> "$GSA_OUTPUT_CSV"
    fi

    rm -rf ${DIR}/${ACCESSION_CODE}*xlsx

  else
    echo "Skipping $STUDY_ACCESSION (already found in ENA)"
  fi
done

# -----------------------------
# Step 2: Clean CSV
# -----------------------------
grep -v '^[[:space:]]*$' "$GSA_OUTPUT_CSV" > "${GSA_OUTPUT_CSV}.clean" && \
mv "${GSA_OUTPUT_CSV}.clean" "$GSA_OUTPUT_CSV"

# -----------------------------
# Step 3: Convert + deduplicate columns
# -----------------------------
${DIR}/scripts/csv_to_tsv.py "${GSA_OUTPUT_CSV}"
#/home/jmontero/find_repeated_columns.py "${GSA_OUTPUT_TSV}"
${DIR}/scripts/drop_duplicate_columns.py "${GSA_OUTPUT_TSV}" && \
mv "${GSA_OUTPUT_TSV%.tsv}.nodup.tsv" "${GSA_OUTPUT_TSV}"

# -----------------------------
# Step 4: Add source column
# -----------------------------
awk 'BEGIN{FS=OFS="\t"} NR==1{$(NF+1)="source"} NR>1{$(NF+1)="GSA"} 1' \
"${GSA_OUTPUT_TSV}" > "${GSA_OUTPUT_TSV}.extracol" && \
mv "${GSA_OUTPUT_TSV}.extracol" "${GSA_OUTPUT_TSV}"

# -----------------------------
# Step 5: Remove first column (ID)
# -----------------------------
cut --complement -f 1 "${GSA_OUTPUT_TSV}" > "${GSA_OUTPUT_TSV}_noid" && \
mv "${GSA_OUTPUT_TSV}_noid" "${GSA_OUTPUT_TSV}"

# -----------------------------
# Step 6: Rename columns to unified schema
# -----------------------------
awk 'BEGIN{
    FS=OFS="\t"

    map["Accession"]="run_accession"
    map["Run title"]="run_alias"
    map["BioProject accession"]="study_accession"
    map["Experiment accession"]="experiment_accession"
    map["Run data file type"]="run_data_file_type"
    map["Read filename 1"]="read_filename_1"
    map["Read file1 MD5"]="read_file1_md5"
    map["DownLoad Read file1"]="download_read_file1"
    map["Read filename 2"]="read_filename_2"
    map["Read file2 MD5"]="read_file2_md5"
    map["DownLoad  Read file2"]="download__read_file2"
    map["Index filename 1"]="index_filename_1"
    map["Index file1 MD5"]="index_file1_md5"
    map["DownLoad Index file1"]="download_index_file1"
    map["Index filename 2"]="index_filename_2"
    map["Index file2 MD5"]="index_file2_md5"
    map["DownLoad Index file2"]="download_index_file2"
    map["Reference file name"]="reference_file_name"
    map["MD5 for reference file"]="md5_for_reference_file"
    map["Assembly Name or Accession"]="assembly_name_or_accession"
    map["Assembly Accession URL"]="assembly_accession_url"
    map["other_db"]="other_db"
    map["accession_in_other_db"]="accession_in_other_db"
    map["other_db_url"]="other_db_url"
    map["Experiment title"]="experiment_title"
    map["BioSample name"]="biosample_name"
    map["BioSample accession"]="sample_accession"
    map["Platform"]="instrument_platform"
    map["Library Construction / Experimental Design"]="library_construction_/_experimental_design"
    map["Library name"]="library_name"
    map["Strategy"]="library_strategy"
    map["Source"]="library_source"
    map["Selection"]="library_selection"
    map["Layout"]="library_layout"
    map["Read length for mate1(bp)"]="read_length_for_mate1(bp)"
    map["Read length for mate 2(bp)"]="read_length_for_mate_2(bp)"
    map["Insert size (bp)"]="insert_size_(bp)"
    map["Nominal size (bp)"]="nominal_size_(bp)"
    map["Nominal standard deviation (bp)"]="nominal_standard_deviation_(bp)"
    map["Planned number of cycles"]="planned_number_of_cycles"
    map["Sample name"]="sample_name"
    map["Public description"]="public_description"
    map["Project accession"]="project_accession"
    map["Sample title"]="sample_title"
    map["Organism"]="scientific_name"
    map["Cultivar"]="cultivar"
    map["Biomaterial provider"]="biomaterial_provider"
    map["Tissue"]="tissue"
    map["Age"]="age"
    map["Age unit"]="age_unit"
    map["Dev stage"]="dev_stage"
    map["Cell line"]="cell_line"
    map["Cell type"]="cell_type"
    map["Collected by"]="collected_by"
    map["Collection date"]="collection_date"
    map["Culture collection"]="culture_collection"
    map["Disease"]="disease"
    map["Disease stage"]="disease_stage"
    map["Genotype"]="genotype"
    map["Growth protocol"]="growth_protocol"
    map["Height length"]="height_length"
    map["Isolation source"]="isolation_source"
    map["Latitude longitude"]="latitude_longitude"
    map["Phenotype"]="phenotype"
    map["Population"]="population"
    map["Type"]="type"
    map["Sex"]="sex"
    map["Specimen voucher"]="specimen_voucher"
    map["Temperature"]="temperature"
    map["Treatment"]="treatment"
    map["source"]="source"
}

NR==1{
    for(i=1;i<=NF;i++){
        if($i in map) $i=map[$i]
    }
}
{print}
' "${GSA_OUTPUT_TSV}" > "${GSA_OUTPUT_TSV}_renamed" && mv "${GSA_OUTPUT_TSV}_renamed" "${GSA_OUTPUT_TSV}"

# -----------------------------
# Step 7: Cleanup temp files
# -----------------------------
rm "${TMP_OUTPUT}" "${TMP_SAMPLE}" "${TMP_EXPERIMENT}" "${GSA_OUTPUT_CSV}"

echo "Done. Output: $GSA_OUTPUT_TSV"
conda deactivate
