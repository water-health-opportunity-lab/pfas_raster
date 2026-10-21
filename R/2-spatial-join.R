################################################################################
# Organization - WHO LAB
# Project - K01 Aim 1: Surface level PFAS exposure map
# Jordan Fischbach, Dr. Cindy Hu, Claude
# This file joins UCMR3 and UCMR5 data with EPA PWS shapefile
################################################################################
source(here::here("R/0-config.R")) 
################################################################################
# Load relevant raw and intermediate data sets (see 0-config)
ucmr3 <- fread(here("data", "intermediate", "ucmr3_averaged_pfas_values"))
ucmr5 <- fread(here("data", "intermediate", "ucmr5_averaged_pfas_values"))
pws <- readRDS(here("data", "intermediate", "epa_pws.rds"))
################################################################################
################################################################################
# Join ucmr data with pws shape file 
################################################################################
ucmr3_geom <- ucmr3 %>% 
  left_join(
    pws, by = "PWSID"
  )

saveRDS(ucmr3_geom, here("data/intermediate/ucmr3_geom.rds"))

ucmr5_geom <- ucmr5 %>% 
  left_join(
    pws, by = "PWSID"
  )

saveRDS(ucmr5_geom, here("data/intermediate/ucmr5_geom.rds"))

## PWSID missing geometries 
x3 <- ucmr3_geom %>% 
  filter(
    st_is_empty(geometry)
    )
x5 <- ucmr5_geom %>% 
  filter(
    st_is_empty(geometry)
  )

################################################################################
