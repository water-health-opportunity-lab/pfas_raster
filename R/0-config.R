################################################################################
# Organization - WHO LAB
# Project - K01 Aim 1: Surface level PFAS exposure map
# Jordan Fischbach, Dr. Cindy Hu
# Configuration file for global variables, data upload, and file path specifications
################################################################################
# Restore r environment 
renv::restore()
################################################################################
#Load libraries
library(here)
library(renv)

library(tidyverse)
library(data.table)
library(lubridate)

library(sf)
library(terra)

library(ggplot2)

# Global variables
## PFAS included in UCMR3 and UCMR5 respectively (all PFAS in 3 present in 5)
pfas3 <- c("PFBS","PFHpA","PFHxS","PFNA","PFOA","PFOS")
pfas5 <- c("PFOS", "PFOA", "HFPO-DA", "PFHxS", "PFNA", "PFBS", "PFBA", "PFHxA", "PFDA", "6:2 FTS", "8:2 FTS", "4:2 FTS", "ADONA", "11Cl-PF3OUdS", "9Cl-PF3ONS", "NFDHA", "PFEESA", "PFMPA", "PFMBA", "PFDoA", "PFHpS", "PFHpA", "PFPeS", "PFPeA", "PFUnA", "NEtFOSAA", "NMeFOSAA", "PFTA", "PFTrDA")


################################################################################
# Import UCMR3 and 5 data, filter to only PFAS contaminants data, and save locally
################################################################################

## UCMR3 data downloaded from https://www.epa.gov/dwucmr/occurrence-data-unregulated-contaminant-monitoring-rule
## downloaded 09/14/2026 - last file update 04/03/2024
### Click "UCMR 3 Occurrence Data Text Files (zip)" under "UCMR 3 (2013-2015) Occurrence Data" to download

ucmr3 <-  fread(file = here("data", "raw", "ucmr3", "UCMR3_All.txt")) %>% 
  filter(
    Contaminant %in% pfas3)
fwrite(ucmr3, here("data", "intermediate", "ucmr3_pfas_raw"))

##fwrite(ucmr3, here("data", "intermediate", "ucmr3_pfas"))

## UCMR5 data downloaded from https://www.epa.gov/dwucmr/occurrence-data-unregulated-contaminant-monitoring-rule
## downloaded 10/16/2026 - last file update 10/15/2026
### Click "UCMR 5 Occurrence Data Text Files (zip)" under "UCMR 5 (2023-2025) Occurrence Data" to download
ucmr5 <- fread(file = here("data", "raw", "ucmr5", "UCMR5_All.txt"))%>% 
  filter(
    Contaminant %in% pfas5)

fwrite(ucmr5, here("data", "intermediate", "ucmr5_pfas_raw"))

################################################################################
# Import EPA PWIS Map
################################################################################
## Version 3.0 downloaded from github (https://github.com/USEPA/ORD_SAB_Model/tree/main/Output_Data) (last updated: 03/17/2026; accessed: 10/09/2026)
pws <- read_sf(here("data", "raw", "EPA_CWS_V1")) %>% 
  select(PWSID, geometry)
saveRDS(pws, here("data", "intermediate", "epa_pws.rds"))

