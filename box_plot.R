options(repos = c(CRAN = "https://cloud.r-project.org/"))

#install.packages("ggplot2")
#install.packages("dplyr")
# Load necessary libraries
library(ggplot2)
library(dplyr)

# Load data
data <- read.table("final_extracted_tpm_with_sample_info.tsv", header = TRUE, sep = "\t")

# Check if the required columns exist
if (!all(c("filename", "tpm_unstranded", "sample_info") %in% colnames(data))) {
    stop("Input data must contain 'filename', 'tpm_unstranded', and 'sample_info' columns.")
}

# Calculate log2(TPM + 1)
data$log2_tpm <- log2(data$tpm_unstranded + 1)

# Filter the data for Primary Tumor and Solid Tissue Normal
data_filtered <- data %>%
    filter(sample_info %in% c("Primary Tumor", "Solid Tissue Normal"))

# Perform t-test
p_value <- t.test(log2_tpm ~ sample_info, data = data_filtered)$p.value

# Format p-value to two decimal points
formatted_p_value <- format(p_value, scientific = TRUE, digits = 2)

# Create the boxplot with improved aesthetics
p <- ggplot(data_filtered, aes(x = sample_info, y = log2_tpm, fill = sample_info)) +
    geom_boxplot(alpha = 0.7, outlier.colour = "red", outlier.shape = 16, outlier.size = 2) +
    scale_fill_manual(values = c("Primary Tumor" = "#FF9999", "Solid Tissue Normal" = "#99CCFF")) +
    labs(title = "NKX2-1 Expression in Different Conditions",
         x = "Condition",
         y = "Log2(TPM + 1)") +
    theme(
        panel.background = element_rect(fill = "white"),   # Set panel background to white
        plot.background = element_rect(fill = "white"),    # Set plot background to white
        panel.grid.major = element_blank(),                 # Remove major grid lines
        panel.grid.minor = element_blank(),                 # Remove minor grid lines
        legend.position = "none",
        text = element_text(color = "black")                # Set text color to black
    ) +
    annotate("text", x = 1, y = mean(data_filtered$log2_tpm[data_filtered$sample_info == "Primary Tumor"]), 
             label = paste("n =", sum(data_filtered$sample_info == "Primary Tumor")), 
             size = 3, angle = 90, vjust = -14.5, hjust = 0) +  # Adjust position for Primary Tumor
    annotate("text", x = 2, y = mean(data_filtered$log2_tpm[data_filtered$sample_info == "Solid Tissue Normal"]), 
             label = paste("n =", sum(data_filtered$sample_info == "Solid Tissue Normal")), 
             size = 3, angle = 90, vjust = -14.5, hjust = 0.5) +  # Adjust position for Solid Tissue Normal
    annotate("text", x = 1.5, y = max(data_filtered$log2_tpm) + 0.5,
             label = paste("p-value:", formatted_p_value), size = 4)    

# Save the plot
ggsave("nkx2_1_boxplot.png", plot = p, width = 7, height = 7, dpi = 300)
