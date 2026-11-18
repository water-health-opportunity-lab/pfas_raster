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
# Check duplicate measurements between Jahred, EPA data, and UCMR data
################################################################################

# Liddie x EPA ------------------------------------------------------------
## Keep PWSID, date, contaminant, and concentration for each, lubridate
### Liddie
comparison_liddie <- liddie_state_data %>% 
  rename_with(~ paste0(.x, "_Concentration"), all_of(pfas_liddie)) %>% 
  pivot_longer(
    cols = starts_with(pfas_liddie),
    names_to = c("Contaminant", ".value"),
    names_sep = "_"
  ) %>% 
  select(PWSID, Sample_Collection_Date, Contaminant, Concentration) %>% 
  mutate(Sample_Collection_Date = mdy(Sample_Collection_Date))
### EPA
comparison_epa_state <- epa_state_data %>% 
  select(PWSID, `Sample Date`, Contaminant, `Concentration (ng/L)`) %>% 
  rename(
    Sample_Collection_Date = `Sample Date`,
    Concentration = `Concentration (ng/L)` 
  ) %>% 
  filter(Contaminant %in% pfas_liddie) %>% 
  mutate(Sample_Collection_Date = mdy(Sample_Collection_Date))

## Join Liddie and EPA data by matching PWSID, Date, and Contaminant, "distinct" to keep only 1 value per join
overlap_epa_liddie <- comparison_liddie %>% 
  semi_join(
    comparison_epa_state,
    by = c("PWSID", "Sample_Collection_Date", "Contaminant")) %>% 
  distinct(PWSID, Sample_Collection_Date, Contaminant)
fwrite(overlap_epa_liddie, here("data/intermediate/overlap_epa_liddie.csv"))



################################################################################
# Clean data - needs work
################################################################################
# NA imputation and selection of columns ----------------------------------
# Liddie: Simple substitution with DL/√2, impute 0 if DL missing
liddie_imputed <- liddie_state_data %>% 
  rename_with(~ paste0(.x, "_Concentration"), all_of(pfas_liddie)) %>% 
  pivot_longer(
    cols = starts_with(pfas_liddie),
    names_to = c("Contaminant", ".value"),
    names_sep = "_"
  ) %>% 
  mutate(
    na = is.na(Concentration),
    value = case_when(
      !is.na(Concentration) ~ Concentration,           # 1. has a value: keep it
      !is.na(DL)    ~ DL / sqrt(2),    # 2. NA with a DL: impute DL/√2
      TRUE          ~ 0                # 3. both NA: impute 0
    )
  ) %>% 
  select(PWSID, Sample_Collection_Date, Contaminant, Concentration, detect, na)
  
fwrite(liddie_imputed, here("data/intermediate/liddie_imputed"))

## !!!??? HOW TO IMPUTE THE EPA STATE DATA NAs ???!!!
### Unsure how to run DL/√2 with the current data structure
unique(epa_state_data$`Reporting Level`)
  



