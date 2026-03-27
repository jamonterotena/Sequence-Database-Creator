#!/bin/bash
#--------------------------------------------------------------#
# 1. Compatibility edits:
#       Rename GSA columns to match ENA's
#       Combine instrument_platform with instrument_model in ENA
# 2. Join ENA and GSA tables on common columns
#--------------------------------------------------------------#

DIR="$(dirname "$0")/.."
#/home/jmontero/selecting_accessions/filereports
ENA=${DIR}/ena_filereports.tsv
GSA=${DIR}/gsa_filereports.tsv
OUTPUT=${DIR}/filereports.tsv

echo ""
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo "  ~ MERGING ENA AND GSA DATA ~ "
echo "  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
echo ""


# Rename GSA columns for compatibility
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
' "${GSA}" > "${GSA}_renamed" && mv "${GSA}_renamed" "${GSA}"

# Combine instrument_platform and instrument_model in ENA for compatibility with GSA
paste \
--delimiter="\t" \
<(cut --complement -f 10,11 "${ENA}") \
<(cut -f 10,11 "${ENA}" | tr "\t" " " | sed '1s/.*/instrument_platform/') \
> "${ENA}_tmp" && \
mv "${ENA}_tmp" "${ENA}"

# Merge ENA and GSA on common fields
Rscript $DIR/scripts/merge_tables.R \
full \
${ENA} ${GSA} \
${OUTPUT} \
run_accession,run_alias,study_accession,experiment_accession,experiment_title,sample_accession,instrument_platform,library_name,library_strategy,library_source,library_selection,library_layout,sample_title,scientific_name,source
