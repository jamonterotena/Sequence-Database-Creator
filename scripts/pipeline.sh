#!/bin/bash
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Controls the pipeline that generates a filereport with metadata for the data generated in the study accessions listed
# Note: These scripts do NOT download data directly from ENA/GSA, but instead build extensive metadata, which is very helpful when you have to download data in bulks but selecting the data first, or to simply gain insight.
# ENA -_
#       ==> combined filereport ==> TGRC enrichment ==> CGN enrichment ==> read length enrichment (short/long) ==> publication enrichment
# GSA _-
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
set -euo pipefail

DIR="$(dirname "$0")"
#/home/jmontero/selecting_accessions/filereports/scripts
${DIR}/download_and_concat_filereports_ena.sh
if [[ -f ${DIR}/../ena_filereports.tsv ]] ; then
  ${DIR}/download_and_concat_filereports_gsa.sh
  ${DIR}/rearrange_filereports_and_append.sh
else
  echo "Filereport with ENA entries was not created. Check files"
fi

if [[ -f ${DIR}/../filereports.tsv ]] ; then
  ${DIR}/lookup_tgrc.sh
  ${DIR}/lookup_cgn.sh
  ${DIR}/tgrc_enrichment.sh
  ${DIR}/cgn_enrichment.sh
else
  echo "Filereport combined for ENA & GSA entries was not created. Check files"
fi

if [[ -f ${DIR}/../filereports.tsv ]] ; then
  ${DIR}/readlength_enrichment.sh
else
  echo "TGRC/CGN enrichment seems to have failed. Check files"
fi

if [[ -f ${DIR}/../filereports.tsv ]] ; then
  ${DIR}/lookup_publication.sh
  ${DIR}/publication_enrichment.sh
else
  echo "Read length type enrichment seems to have failed. Check files"
fi

# Sort columns
if [[ -f ${DIR}/../filereports.tsv ]] ; then
  ${DIR}/sort_columns.R ${DIR}/../filereports.tsv ${DIR}/../column_lookup.tsv ${DIR}/../filereports.tsv_temp && \
  mv ${DIR}/../filereports.tsv_temp ${DIR}/../filereports.tsv
else
  echo "Publication enrichment seems to have failed. Check files"
fi

# Remove duplicates
if [[ -f ${DIR}/../filereports.tsv ]] ; then
  head -n 1 ${DIR}/../filereports.tsv > ${DIR}/../filereports.tsv_temp && sort -u <(tail -n +2 ${DIR}/../filereports.tsv) >> ${DIR}/../filereports.tsv_temp
  mv ${DIR}/../filereports.tsv_temp ${DIR}/../filereports.tsv
else
  echo "Column sorting seems to have failed. Check files"
fi

