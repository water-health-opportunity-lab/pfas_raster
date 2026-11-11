################################################################################
# Organization: WHO LAB
# Project: K01 Aim 1: Surface level PFAS exposure map
# Author: Jordan Fischbach, Claude
# Purpose: Maps of PFAS concentrations
################################################################################
source(here::here("R/0-config.R")) 
################################################################################
# Load relevant data ------------------------------------------------------
ucmr3_pfoa_sf <- read_sf(here("data", "final", "ucmr3_PFOA_ave_values.shp"))
ucmr3_pfoa_rast <- rast(here("data/final/ucmr3_PFOA_rast.tif"))
################################################################################
# Check shape and raster files ------------------------------------------------
# UCMR 3 PFOA in NY
## Create NY shape and rasters
zoom_NY <- tigris::states(cb = TRUE, year = 2022) %>% 
  filter(STUSPS == "NY") %>% 
  st_transform(5070)

NY_ucmr3_pfoa_sf <- st_filter(ucmr3_pfoa_sf, zoom_NY)
NY_ucmr3_pfoa_rast <- crop(ucmr3_pfoa_rast, vect(zoom_NY), mask = TRUE)

pdf(file = here("figures/NY_ucmr3_pfoa_sf.pdf"))
ggplot(data = NY_ucmr3_pfoa_sf) +
  geom_sf(aes(fill = mean), color = NA) +
  scale_fill_viridis_c(
    limits = c(0.007, 0.01),
    oob = scales::squish,
    breaks = c(0.0, 0.025, 0.05, 0.075, 0.1),
    labels = c("0.01", "0.025", "0.05", "0.075", ">0.1"),
    na.value = "transparent"
  ) +
  theme_void() + 
  coord_sf(datum = NA) 
dev.off()

pdf(file = here("figures/NY_ucmr3_pfoa_rast.pdf"))
ggplot() +
  geom_spatraster(data = NY_ucmr3_pfoa_rast) +
  scale_fill_viridis_c() +
  coord_sf(datum = NA) +
  theme_void() 
dev.off()

# UCMR 5 PFOA in NY
ucmr5_pfoa_sf <- read_sf(here("data", "final", "ucmr5_PFOA_ave_values.shp"))


