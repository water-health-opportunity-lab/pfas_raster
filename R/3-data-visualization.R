################################################################################
# Organization: WHO LAB
# Project: K01 Aim 1: Surface level PFAS exposure map
# Author: Jordan Fischbach, Claude
# Purpose: Maps of PFAS concentrations
################################################################################
source(here::here("R/0-config.R")) 
################################################################################
# UCMR 3 ------------------------------------------------------------------
ggplot(
  data = ucmr5_
)

