#!/usr/bin/env Rscript
#-------------------------------------------------------------------------------------------------------------------------------------------#
# Sort column according to the col order in columns_lookup.tsv
# OFF: By default converts empty lines to NA
# 	* Swich off by adding `na = character()` to `write_tsv()`
#-------------------------------------------------------------------------------------------------------------------------------------------#

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
})

# ---- Parse arguments ----
args <- commandArgs(trailingOnly = TRUE)

if(length(args) < 3){
  stop("Usage:
  Rscript reorder_columns.R filereports.tsv column_lookup.tsv output.tsv")
}

input_file  <- args[1]
lookup_file <- args[2]
output_file <- args[3]

# ---- Read data ----
df <- read_tsv(input_file, show_col_types = FALSE)
lookup <- read_tsv(lookup_file, show_col_types = FALSE)

# ---- Extract desired column order ----
desired_order <- lookup$column

# ---- Keep only columns that exist in df ----
existing_cols <- desired_order[desired_order %in% colnames(df)]

# ---- Warn about missing columns ----
missing_cols <- setdiff(desired_order, colnames(df))
if(length(missing_cols) > 0){
  warning("Columns not found in input file: ",
          paste(missing_cols, collapse = ", "))
}

# ---- Reorder ----
df_reordered <- df %>% select(all_of(existing_cols))

# ---- Write output ----
write_tsv(df_reordered, output_file, na = "")

cat("Done. Output written to:", output_file, "\n")
