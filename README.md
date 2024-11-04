**README for NKX2-1 Expression Analysis Pipeline**
**Overview**
This repository contains a pipeline for analyzing RNA-seq data to extract and visualize the expression levels of the NKX2-1 gene across various samples. The pipeline processes sample information, extracts relevant TPM (Transcripts Per Million) data, and generates a box plot for NKX2-1 expression.

**Requirements**
To run the pipeline, you will need:
Snakemake
R and Rscript
Required R packages for plotting (e.g., ggplot2)
UNIX-like environment (Linux or macOS)

**Pipeline Rules**
get_tsv_files:

Generates a list of .rna_seq.augmented_star_gene_counts.tsv files from the specified directory.
extract_rna_seq_augmented_sample_info:

Extracts relevant sample information for RNA-seq augmented data and outputs it to a text file.
add_sample_info:

Combines the extracted TPM data with the sample information, creating a final table that includes filenames, TPM values, and additional sample info.
extract_tpm:

Extracts TPM values specifically for the NKX2-1 gene from the list of TSV files and outputs it in a structured format.
plot_nkx2_1_expression:

Runs the R script to generate a box plot of NKX2-1 expression levels across samples, outputting a PNG file.

**Input Files**
gdc_sample_sheet.2024-06-17.tsv: This file contains metadata for the samples. It should be in the same directory as the Snakefile.
R script (box_plot.R): This script is responsible for generating the expression box plot.

**Output Files**
final_extracted_tpm_with_sample_info.tsv: A consolidated TSV file containing TPM values for NKX2-1 along with corresponding sample information.
nkx2_1_boxplot.png: A visual representation of NKX2-1 expression levels across samples.
