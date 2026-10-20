################################################################################
# Organization - WHO LAB
# Project - K01 Aim 1: Surface level PFAS exposure map
# Jordan Fischbach, Dr. Cindy Hu, Claude
# This file creates individual raster files for each PFAS
################################################################################
source(here::here("R/0-config.R")) 
################################################################################
# Load relevant raw and intermediate data sets (see 0-config)
ucmr3 <- fread(here("data", "intermediate", "ucmr3_geom"))
ucmr5 <- fread(here("data", "intermediate", "ucmr5_geom"))
pws <- readRDS(here("data", "intermediate", "epa_pws.rds"))
################################################################################

