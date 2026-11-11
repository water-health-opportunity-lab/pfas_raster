################################################################################
# Organization: WHO LAB
# Project: K01 Aim 1: Surface level PFAS exposure map
# Author: Jordan Fischbach, Claude
# Purpose: This file creates individual shapefiles and 1 km raster files for each PFAS
################################################################################
source(here::here("R/0-config.R")) 
################################################################################
# Load relevant raw and intermediate data sets
ucmr3_averaged_values <- fread(here("data", "intermediate", "ucmr3_averaged_values"))
ucmr5_averaged_values <- fread(here("data", "intermediate", "ucmr5_averaged_values"))
pws <- readRDS(here("data", "intermediate", "epa_pws.rds"))
zip3 <- readRDS(here("data/intermediate/zip3"))
zip5 <- readRDS(here("data/intermediate/zip5"))
################################################################################
# Create Raster and shapefiles for each PFAS for UCMR3 and UCMR5
################################################################################
# Prepare variables for function
# Create projection for raster files - CONUS, transformed to Albers equal area conic projection
conus <- tigris::states(cb = TRUE, year = 2022) %>% 
  st_crop(c(xmin = -125.0017, ymin = 20, xmax = -66.9346, ymax = 49.3844)) %>% #Soo-Yeon
  st_transform(5070) 

# CONUS 1km x 1km template to be filled bellow 
template <- rast(vect(conus),  resolution = 1000)

# Keep only PWS in CONUS for raster files (shape files use pws)
pws_conus <- pws %>% 
  st_transform(5070) %>% 
  st_filter(conus)

# Set zip files as shape files and set coordinate system for all other spatial objects
pws <- st_transform(pws, 5070)
zip3 <- st_as_sf(zip3)
zip3 <- st_transform(zip3, 5070)
zip5 <- st_as_sf(zip5)
zip5 <- st_transform(zip5, 5070)

# 1. Create function: Create shape and raster files of UCMR data ------------------------------------

shape_and_raster_files_ucmr_pfas <- function(ucmr_data, 
                                pws, 
                                pfas_list,
                                ucmr_round, 
                                zip) {

  for (i in pfas_list) {
    # Status update
    print(paste("processing pfas", i))
    
    #1. Create shapefile
    pfas_sf <- ucmr_data %>% 
      filter(Contaminant == i) %>% 
      left_join(pws, by = "PWSID") %>% 
      left_join(zip, by = "PWSID", suffix = c("", "_zip")) %>% 
      mutate(geometry = 
               if_else(st_is_empty(geometry), 
                       geometry_zip, 
                       geometry)) %>% 
      select(-geometry_zip) %>% 
      st_as_sf() %>% 
      rename(pfas = Contaminant) %>% 
      write_sf(here("data/final/", paste0("ucmr", ucmr_round, "_", str_replace_all(i, "[: ]", "_"), "_", "ave_values.shp"))) 
    
    #2. Create raster file
    pfas_sf %>% 
      vect() %>% 
      rasterize(template, field = "mean", fun = "max") %>% 
      writeRaster(here("data", "final", paste0("ucmr", ucmr_round, "_", str_replace_all(i, "[: ]", "_"), "_", "rast.tif")), overwrite = TRUE)
    
  }
}

# 2a. Create UCMR 3 shape and raster files -----------------------------------------------
shape_and_raster_files_ucmr_pfas(
  ucmr_data = ucmr3_averaged_values,
  pws = pws, 
  pfas_list = pfas3,
  ucmr_round = 3,
  zip = zip3
  )

# 2b. Create UCMR 5 shape files -----------------------------------------------
shape_and_raster_files_ucmr_pfas(
  ucmr_data = ucmr5_averaged_values,
  pws = pws_conus, 
  pfas_list = pfas5,
  ucmr_round = 5,
  zip = zip5
)



# posterior file check----------------------------------------------------
# how many empty geometries in each shape file?

shp_files <- list.files(here("data", "final"), pattern = "_ave_values\\.shp$", full.names = TRUE)

geom_check <- map_dfr(shp_files, \(f) {
  shp <- read_sf(f)
  tibble(
    file = basename(f),
    with_geom = sum(!st_is_empty(shp)),
    without_geom = sum(st_is_empty(shp))
  )
})

geom_check



