################################################################################
# Organization: WHO LAB
# Project: K01 Aim 1: Surface level PFAS exposure map
# Author(s): Jordan Fischbach, Claude
# Purpose: EPA and Jahred collected state PFAS data - manipulate, clean, and explore data
################################################################################
source(here::here("R/0-config.R")) 
################################################################################
# Load relevant raw data sets (see 0-config) --------------
liddie_state_data <- fread(here("data/raw/Jahred_PFAS_SSD_112026(in).csv"))
epa_state_data <- fread(here("data/raw/EPA_state_PFAS_data_112026.xlsx"))

ucmr3_select <- fread(here("data/intermediate/ucmr3_select"))
ucmr5_select <- fread(here("data/intermediate/ucmr5_select"))

################################################################################
# Clean EPA data
################################################################################
epa_state_data_clean <- epa_state_data %>% 
  

################################################################################
# Check duplicate measurements between Jahred and EPA data
################################################################################
# Keep PWSID, date, contaminant, and concentration for each
liddie_duplicate_comparison <- liddie_state_data %>% 
  select(PWSID, Sample_Collection_Date, PFBS, PFHxS, PFOS, PFOA, PFNA) %>% 
  pivot_longer(
    cols = starts_with("PF"),
    names_to = "Contaminant",
    values_to = "Concentration")

epa_duplicate_comparison <- epa_state_data %>% 
  select(PWSID, `Sample Date`, Contaminant, Concentration)


################################################################################
# Select relevant columns 
################################################################################
liddie_state_data_select <- liddie_state_data %>% 
  select(PWSID, Sample_Collection_Date, PFBS, PFHxS, PFOS, PFOA, PFNA
  )



