#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

# ---- Parse arguments ----
args <- commandArgs(trailingOnly = TRUE)

if(length(args) < 5){
  stop("Usage:
  Rscript merge_tsv.R jointype file1.tsv file2.tsv output.tsv col1,col2,...
  
  jointype: left | right | full | anti")
}

jointype <- args[1]
file1 <- args[2]
file2 <- args[3]
output <- args[4]
join_cols <- strsplit(args[5], ",")[[1]]

cat("Join type:", jointype, "\n")
cat("File1:", file1, "\n")
cat("File2:", file2, "\n")
cat("Output:", output, "\n")
cat("Join columns:", paste(join_cols, collapse=", "), "\n\n")

# ---- Read data ----
df1 <- read_tsv(file1, show_col_types = FALSE, progress = FALSE)
df2 <- read_tsv(file2, show_col_types = FALSE, progress = FALSE)

# ---- Check columns ----
missing1 <- setdiff(join_cols, colnames(df1))
missing2 <- setdiff(join_cols, colnames(df2))

if(length(missing1) > 0){
  stop(paste("Missing in file1:", paste(missing1, collapse=", ")))
}
if(length(missing2) > 0){
  stop(paste("Missing in file2:", paste(missing2, collapse=", ")))
}

# ---- Select join type ----
merged <- switch(
  jointype,
  left  = left_join(df1, df2, by = join_cols),
  right = right_join(df1, df2, by = join_cols),
  full  = full_join(df1, df2, by = join_cols),
  anti  = anti_join(df1, df2, by = join_cols),
  stop("Invalid join type. Use: left, right, full, or anti")
)

# ---- Optional: reorder columns (keys first) ----
merged <- merged %>%
  select(all_of(join_cols), everything())

# ---- Write output ----
write_tsv(merged, output, na = "")

cat("Done\n")
