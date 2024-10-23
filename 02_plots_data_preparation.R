# Load required libraries
library(fs)
library(tidyverse)
library(stringr)
rm(list = ls())

# Define the folder path
folder_path <- "S:/guiInputsv4 (eSolutions Admin)"

# Define a function to read an .rds file and extract metadata
read_rds_file_metadata <- function(file_path) {
  plot <- read_rds(file_path)
  file_name <- basename(file_path)
  
  # Extract port and MNT from the file name
  port <- str_extract(file_name, "(?<=-)[A-Z]{3}(?=_)")
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
    port = factor(port),
    MNT = factor(MNT, levels = c("BAU", "HULL", "CULL"))
  )
}

# List .rds files containing "PlotSmall" in their names
node_status_plots_files <- dir_ls(folder_path, recurse = TRUE, regexp = ".*nodeStatusPlotSmall\\.rds$")

# Process the files and extract metadata
nodes_status_plots <- 
  node_status_plots_files %>%
  map(read_rds_file_metadata)

# Save the combined list of plots and metadata
write_rds(nodes_status_plots, "node_status_plots.rds", compress = 'xz')

#######Industry plots########

# List .rds files containing "industry" in their names
industry_files <- dir_ls(folder_path, recurse = TRUE, regexp = ".*industryPlotSmall.*\\.rds$")

# Process the files and extract metadata
industry_plots <- 
  industry_files %>%
  map(read_rds_file_metadata)

# Save the combined list of plots and metadata
write_rds(industry_plots, "industry_plots.rds", compress = 'xz')


## Industry tables ---
# Define a function to read an .rds file and extract relevant data and factors
read_industry_table <- function(file_path) {
  data <- read_rds(file_path)  # Read the .rds file
  
  # Extract port and MNT from the file name
  file_name <- basename(file_path)
  port <- str_extract(file_name, "(?<=-)[A-Z]{3}(?=_)")
  MNT <- str_extract(file_name, "BAU|OUTHULL|CULL")
  
  # Map MNT values to new factor levels
  MNT <- case_when(
    MNT == "OUTHULL" ~ "HULL",
    TRUE ~ MNT
  )
  
  # Create a tibble with the relevant data and factors
  tibble(
    Industry = data$Industry,
    Cumulative_PPP_m2 = data$Cumulative.PPP.m.2,
    port = factor(port),
    MNT = factor(MNT, levels = c("BAU", "HULL", "CULL"))
  )
}

# List .rds files containing "industryTable" in their names
industry_tables_files <- dir_ls(folder_path, recurse = TRUE, regexp = ".*industryTable.*\\.rds$")

# Process the files and create a combined tibble
industry_data <- 
  industry_tables_files %>%
  map_dfr(read_industry_table) %>% 
  mutate(Industry = fct_recode(Industry, Commercial = "Comm", Recreational = "Rec")) %>% 
  rename(`Propagule Pressure` = "Cumulative_PPP_m2")

# View the final tibble
write_csv(industry_data, 'industry_tables.csv')
