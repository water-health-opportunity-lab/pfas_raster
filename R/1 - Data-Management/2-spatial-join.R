################################################################################
# Organization - WHO LAB
# Project - K01 Aim 1: Surface level PFAS exposure map
# Jordan Fischbach, Dr. Cindy Hu, Claude
# This file joins UCMR3 and UCMR5 data with PWS 
################################################################################
source(here::here("R/0-config.R")) 

################################################################################
# Load relevant raw and intermediate data sets (see 0-config)
ucmr3 <- fread(here("data", "intermediate", "ucmr3_averaged_pfas_values"))
ucmr5 <- fread(here("data", "intermediate", "ucmr5_averaged_pfas_values"))
################################################################################

################################################################################