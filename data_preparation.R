# Load required libraries
library(fs)
library(sf)
library(tidyverse)

# Define the folder path
folder_path <- "S:/guiInputsv2 (eSolutions Admin)"

# Define a function to read an .rds file and add factor columns
read_rds_file <- function(file_path) {
  data <- read_rds(file_path)
  file_name <- basename(file_path)
  
  # Extract port, MNT, and type (nodes or edges) from the file name
  port <- str_extract(file_name, "AUK|LYT|TAU")
  MNT <- str_extract(file_name, "BAU|OUTHULL|CULL")
  type <- str_extract(file_name, "nodes|edges")
  
  # Map MNT values to new factor levels
  MNT <- case_when(
    MNT == "OUTHULL" ~ "HULL",
    TRUE ~ MNT
  )
  
  # Add new columns to the data
  data %>%
    mutate(source_file = file_name,
           port = factor(port, levels = c("AUK", "LYT", "TAU")),
           MNT = factor(MNT, levels = c("BAU", "HULL", "CULL")),
           type = factor(type, levels = c("nodes", "edges")))
}

# List .rds files for nodes and edges separately
nodes_files <- dir_ls(folder_path, recurse = TRUE, regexp = ".*nodes.*\\.rds$")
edges_files <- dir_ls(folder_path, recurse = TRUE, regexp = ".*edges.*\\.rds$")

# Process and combine nodes files
nodes_data <- 
  nodes_files %>%
  map(read_rds_file) %>%
  bind_rows()

# Save the combined nodes data
write_rds(nodes_data, "combined_nodes_data.rds", compress = 'xz')

# Process and combine edges files
edges_data <- edges_files %>%
  map(read_rds_file) %>%
  bind_rows()

# Save the combined edges data
write_rds(edges_data, "combined_edges_data.rds", compress = 'xz')
