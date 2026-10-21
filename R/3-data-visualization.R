################################################################################
# Organization: WHO LAB
# Project: K01 Aim 1: Surface level PFAS exposure map
# Author: Jordan Fischbach, Claude
# Purpose: Maps of PFAS concentrations
################################################################################
source(here::here("R/0-config.R")) 
################################################################################
# UCMR 3 ------------------------------------------------------------------
ucmr3_pfoa_sf <- read_sf(here("data", "final", "ucmr3_PFOA_ave_values.shp"))
ucmr5_pfoa_sf <- read_sf(here("data", "final", "ucmr5_PFOA_ave_values.shp"))

ggplot(ucmr3_pfoa_sf) +
  geom_sf(aes(fill = mean), color = NA)

ggplot(ucmr5_pfoa_sf) +
  geom_sf(aes(fill = mean), color = NA)


