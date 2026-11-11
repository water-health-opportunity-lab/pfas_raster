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

ucmr3_pfoa_rast <- rast(here("data/final/ucmr3_PFOA_rast.tif"))

pdf(file = here("figures/ucmr3_pfoa_sf.pdf"))
ggplot(ucmr3_pfoa_sf) +
  geom_sf(aes(fill = mean), color = NA) +
  scale_fill_viridis_c(trans = "log10")+
  theme_minimal() 
dev.off()

pdf(file = here("figures/ucmr3_pfoa_rast.pdf"))
ggplot() +
  geom_spatraster(data = ucmr3_pfoa_rast) +
  scale_fill_viridis_c(trans = "log10", na.value = "transparent")+
  theme_minimal() 
dev.off()


