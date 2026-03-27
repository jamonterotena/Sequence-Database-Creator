#!/usr/bin/env python3
import sys
from pathlib import Path

file = sys.argv[1]
out_file = Path(file).with_suffix(".nodup.tsv")

with open(file, "r", encoding="utf-8", errors="replace") as f_in, \
     open(out_file, "w", encoding="utf-8") as f_out:

    header = f_in.readline().rstrip("\n").split("\t")

    seen = set()
    keep_idx = []

    # keep first occurrence only
    for i, col in enumerate(header):
        if col not in seen:
            seen.add(col)
            keep_idx.append(i)

    # write cleaned header
    f_out.write("\t".join(header[i] for i in keep_idx) + "\n")

    # process rows
    for line in f_in:
        row = line.rstrip("\n").split("\t")
        filtered = [(row[i] if i < len(row) else "") for i in keep_idx]
        f_out.write("\t".join(filtered) + "\n")

#print(f"[OK] Written: {out_file}")
