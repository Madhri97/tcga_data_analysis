rule all:
    input:
        "nkx2_1_boxplot.png"  # Ensure this file is generated

rule get_tsv_files:
    output:
        "tsv_file_list.txt"
    run:
        import os
        import glob

        TSV_FILES = glob.glob("**/*.rna_seq.augmented_star_gene_counts.tsv", recursive=True)

        with open(output[0], 'w') as f:
            for file in TSV_FILES:
                f.write(file + "\n")

rule extract_tpm:
    input:
        "tsv_file_list.txt"  # Use the generated file list
    output:
        "extracted_tpm_unstranded.tsv"
    shell:
        """
        echo -e "filename\\ttpm_unstranded" > {output}  # Ensure tab separation
        while read -r file; do
            if grep -qw 'NKX2-1' "$file"; then
                grep -w 'NKX2-1' "$file" | awk -F '\\t' -v filename="$file" '($2 == "NKX2-1") {{ 
                    print filename "\\t" $7 
                }}' >> {output}
            else
                echo "Warning: NKX2-1 not found in $file" >&2
            fi
        done < {input}
        """

rule extract_rna_seq_augmented_sample_info:
    input:
        "gdc_sample_sheet.2024-06-17.tsv"
    output:
        "rna_seq_augmented_sample_info.txt"
    shell:
        """
        grep '.rna_seq.augmented_' {input} | awk -F'\\t' '{{print $2 "\\t" $NF}}' > {output}
        """

rule add_sample_info:
    input:
        tpm_file="extracted_tpm_unstranded.tsv",
        sample_info="rna_seq_augmented_sample_info.txt"  # Use the output from the previous rule
    output:
        "final_extracted_tpm_with_sample_info.tsv"
    shell:
         """
        sort -k1,1 {input.sample_info} > sorted_sample_sheet.tsv
        
        awk -F'/' '{{print $2 "\t" $NF}}' {input.tpm_file} | sort -k1,1 > sorted_tpm_file.tsv

        echo -e "filename\ttpm_unstranded\tsample_info" > {output}  # Create header
        join -t$'\t' sorted_sample_sheet.tsv sorted_tpm_file.tsv | awk -F'\t' '{{print $1 "\t" $3 "\t" $2}}' >> {output}

        rm sorted_sample_sheet.tsv sorted_tpm_file.tsv
        """

rule plot_nkx2_1_expression:
    input:
        "final_extracted_tpm_with_sample_info.tsv",
         script="box_plot.R"
    output:
        "nkx2_1_boxplot.png"
    shell:
        "Rscript {input.script}"
