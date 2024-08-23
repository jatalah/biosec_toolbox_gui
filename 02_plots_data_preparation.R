# Load required libraries
library(fs)
library(tidyverse)
library(stringr)
rm(list = ls())

# Define the folder path
folder_path <- "S:/guiInputsv2 (eSolutions Admin)"

# Define a function to read an .rds file and extract metadata
read_rds_file_metadata <- function(file_path) {
  plot <- read_rds(file_path)
  file_name <- basename(file_path)
  
  # Extract port and MNT from the file name
  port <- str_extract(file_name, "AUK|LYT|TAU")
  MNT <- str_extract(file_name, "BAU|OUTHULL|CULL")
  
  # Map MNT values to new factor levels
  MNT <- case_when(
    MNT == "OUTHULL" ~ "HULL",
    TRUE ~ MNT
  )
  
  # Return a list containing the plot and its metadata
  list(
    plot = plot,
    source_file = file_name,
    port = factor(port, levels = c("AUK", "LYT", "TAU")),
    MNT = factor(MNT, levels = c("BAU", "HULL", "CULL"))
  )
}

# List .rds files containing "PlotSmall" in their names
node_status_plots_files <- dir_ls(folder_path, recurse = TRUE, regexp = ".*nodeStatusPlotSmall*\\.rds$")

# Process the files and extract metadata
nodes_status_plots <- 
  node_status_plots_files %>%
  map(read_rds_file_metadata)

# Save the combined list of plots and metadata
write_rds(nodes_status_plots, "node_status_plots.rds", compress = 'xz')

#######Indutrsy plots########

# List .rds files containing "industry" in their names
industry_files <- dir_ls(folder_path, recurse = TRUE, regexp = ".*industry.*\\.rds$")

# Process the files and extract metadata
industry_plots <- 
  industry_files %>%
  map(read_rds_file_metadata)

# Save the combined list of plots and metadata
write_rds(industry_plots, "industry_plots.rds", compress = 'xz')