#!/usr/bin/env python3
import csv
import sys
from pathlib import Path

def csv_to_tsv(input_file: str):
    input_path = Path(input_file)

    # output: same name but .tsv
    output_path = input_path.with_suffix(".tsv")

    with open(input_path, "r", encoding="utf-8", errors="replace", newline="") as f_in, \
         open(output_path, "w", encoding="utf-8", newline="") as f_out:

        reader = csv.reader(f_in)
        writer = csv.writer(f_out, delimiter="\t", lineterminator="\n")

        for row in reader:
            if not row:
                continue
            writer.writerow(row)

   # print(f"[OK] TSV written to: {output_path}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 csv_to_tsv.py <input.csv>")
        sys.exit(1)

    csv_to_tsv(sys.argv[1])
#/vol/ribes/jmontero/miniconda3/bin python3
