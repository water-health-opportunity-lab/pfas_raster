################################################################################
# Organization - WHO LAB
# Project - K01 Aim 1: Surface level PFAS exposure map
# Jordan Fischbach, Dr. Cindy Hu, Claude
# This file creates individual raster files for each PFAS
################################################################################
source(here::here("R/0-config.R")) 
################################################################################
# Load relevant raw and intermediate data sets (see 0-config)
ucmr3_averaged_pfas_values <- fread(here("data", "intermediate", "ucmr3_averaged_pfas_values"))
ucmr5_averaged_pfas_values <- fread(here("data", "intermediate", "ucmr5_averaged_pfas_values"))
pws <- readRDS(here("data", "intermediate", "epa_pws.rds"))
################################################################################
# 1. Create function: Rasterize UCMR data ------------------------------------

rasterize_ucmr_pfas <- function(data, 
                                pws, 
                                pfas_list,
                                ucmr_round){
  for (i in pfas_list) {
    print(paste("processing pfas", i))
    data %>% 
      filter(Contaminant == i) %>% 
      left_join(pws, by = "PWSID") %>% 
      st_as_sf() %>% 
      rename(pfas = Contaminant) %>% 
      write_sf(here("data/final/", paste0("ucmr", ucmr_round, "_", str_replace_all(i, "[: ]", "_"), "_", "ave_values.shp")))
    
  }
}


# 2a. Create UCMR 3 shape files -----------------------------------------------
rasterize_ucmr_pfas(
  data = ucmr3_averaged_pfas_values,
  pws = pws, 
  pfas_list = pfas3,
  ucmr_round = 3
  )

# 2b. Create UCMR 5 shape files -----------------------------------------------
rasterize_ucmr_pfas(
  data = ucmr5_averaged_pfas_values,
  pws = pws, 
  pfas_list = pfas5,
  ucmr_round = 5
)


