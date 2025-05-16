#!/bin/bash

for file in conformacions_wt/*.pdb; do
    if [[ $(basename "$file") != "test.pdb" ]]; then
        base_name=$(basename "$file" .pdb)
        awk '{if ($6 == "19" && $4 == "HIS") {if ($3 != "N" && $3 != "CA" && $3 != "C" && $3 != "O" && $3 != "CB") next; sub("HIS", "ARG", $0)} print}' "$file" > "conformacions_mut/${base_name}_ARG.pdb"
        awk '{if ($6 == "19" && $4 == "HIS") {if ($3 != "N" && $3 != "CA" && $3 != "C" && $3 != "O" && $3 != "CB") next; sub("HIS", "LYS", $0)} print}' "$file" > "conformacions_mut/${base_name}_LYS.pdb"
        awk '{if ($6 == "19" && $4 == "HIS") {if ($3 != "N" && $3 != "CA" && $3 != "C" && $3 != "O" && $3 != "CB") next; sub("HIS", "ASP", $0)} print}' "$file" > "conformacions_mut/${base_name}_ASP.pdb"
        awk '{if ($6 == "18" && $4 == "ARG") {if ($3 != "N" && $3 != "CA" && $3 != "C" && $3 != "O" && $3 != "CB") next; sub("ARG", "HIS", $0)} print}' "$file" > "conformacions_mut/${base_name}_HIS.pdb"
    fi
done