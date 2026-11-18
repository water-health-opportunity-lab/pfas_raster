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
ucmr5_pfoa_sf <- read_sf(here("data/final/ucmr5_PFOA_ave_values.shp"))
ucmr_pfoa_rast <- rast(here("data/final/ucmr5_PFOA_rast.tif"))
################################################################################
# Data check: NY PFAS shape and raster maps -----------------------------------
# Create NY outline
zoom_NY <- tigris::states(cb = TRUE, year = 2022) %>% 
  filter(STUSPS == "NY") %>% 
  st_transform(5070)
# Crop shape and rast files to NY
NY_ucmr3_pfoa_sf <- st_filter(ucmr3_pfoa_sf, zoom_NY)
NY_ucmr3_pfoa_rast <- crop(ucmr3_pfoa_rast, vect(zoom_NY), mask = TRUE)

# NY UCMR PFOA shape file map
pdf(file = here("figures/NY_ucmr3_pfoa_sf.pdf"))

ggplot(data = NY_ucmr3_pfoa_sf) +
  
  geom_sf(aes(fill = mean), color = NA) +
  scale_fill_viridis_c(transform = "log10")+
  theme_void() + 
  coord_sf(datum = NA) 

dev.off()

# NY UCMR 3 PFOA Raster map
pdf(file = here("figures/NY_ucmr3_pfoa_rast.pdf"))

ggplot() +
  
  geom_spatraster(data = NY_ucmr3_pfoa_rast) +
  scale_fill_viridis_c(na.value = "transparent") +
  coord_sf(datum = NA) +
  theme_void() 

dev.off()


# Data check: US PFOA shape and raster maps -------------------------------
# UCMR PFOA shape file map
pdf(file = here("figures/ucmr3_pfoa_sf.pdf"))

ggplot(data = ucmr3_pfoa_sf) +
  
  geom_sf(aes(fill = mean), color = NA) +
  scale_fill_viridis_c(transform = "log10")+
  theme_void() + 
  coord_sf(datum = NA) 

dev.off()

# UCMR 3 PFOA Raster map
pdf(file = here("figures/ucmr3_pfoa_rast.pdf"))

ggplot() +
  
  geom_spatraster(data = ucmr3_pfoa_rast) +
  scale_fill_viridis_c(na.value = "transparent") +
  coord_sf(datum = NA) +
  theme_void() 

dev.off()







