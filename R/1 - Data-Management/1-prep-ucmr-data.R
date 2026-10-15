################################################################################
# Organization - WHO LAB
# Project - K01 Aim 1: Surface level PFAS exposure map
# Jordan Fischbach, Claude
# This file imports UCMR3 and UCMR5 data and conducts manipulation, cleaning, and characterization
################################################################################
source(here::here("R/0-config.R")) #??? why source config file at beginning of scripts???

################################################################################
# Investigate UCMR data 
################################################################################
# Does each PWS facility have a reading each year for each PFAS? A: No.
## Filter by individual PWS facility for unique readings of PFAS per year
### UCMR3
check3 <- ucmr3 %>%
  mutate(
    year = year(mdy(CollectionDate))
      ) %>%
  mutate(
    PWSID_FID = paste0(PWSID, "_", FacilityID)
  ) %>%
  distinct(
    PWSID, PWSID_FID, Contaminant, year
  ) %>%
  count(
    PWSID,PWSID_FID,
    name = "n"
    ) 

#### Check distribution of unique yearly readings
hist(check3$n)

#### Check n facilities with more than 2 unique years of data (measurments span >12 month period)
outlier3 <- check3 %>% 
  filter(
    !(n %in% c(6, 12))
  )

#### n NAs 
nas_ucmr3 <- ucmr3 %>% 
  group_by(Contaminant) %>% 
  count(is.na(AnalyticalResultValue)) %>% 
  rename(is_na = "is.na(AnalyticalResultValue)")

### UCMR5
check5 <- ucmr5 %>%
  mutate(
    year = year(mdy(CollectionDate))
  ) %>%
  mutate(
    PWSID_FID = paste0(PWSID, "_", FacilityID)
  ) %>%
  distinct(
    PWSID_FID, Contaminant, year
  ) %>%
  count(
    PWSID_FID,
    name = "n"
  )

#### Check distribution of unique yearly readings
hist(check5$n)

#### Check n facilities with more than 2 unique years of data
outlier5 <- check5 %>% 
  filter(
    !(n %in% c(29, 58))
  )

#### n NAs 
nas_ucmr5 <- ucmr5 %>% 
  group_by(Contaminant) %>% 
  count(is.na(AnalyticalResultValue)) %>% 
  rename(is_na = "is.na(AnalyticalResultValue)")
#### Plot nas per PFAS, log scale to show detects 
ggplot(nas_ucmr5, aes(x = Contaminant, y = n, fill = is_na)) +
  geom_col(position = position_dodge2(preserve = "single"), width = 0.8) +
  scale_x_discrete(limits = pfas5) +
  scale_y_log10(labels = scales::label_comma()) +
  scale_fill_manual(
    values = c("FALSE" = "#FF0000", "TRUE" = "#999999"),
    labels = c("FALSE" = "Detect", "TRUE" = "Non-detect")
  ) +
  labs(
    x = NULL,
    y = "Number of sample results (log scale)",
    fill = NULL,
    title = "UCMR 5 PFAS detects vs. non-detects"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "top"
  )
################################################################################
# Clean data - filter columns and impute for NAs
################################################################################
# Select columns 
ucmr3 <- ucmr3 %>% 
  select(
    PWSID, Contaminant, MRL, AnalyticalResultValue)
ucmr5 <- ucmr5 %>% 
  select(
    PWSID, Contaminant, MRL, AnalyticalResultValue) 

# Impute NA values as DL/sqrt 2 (Hu 2021 - Table 1)
## Create table of MRL/√2 values for each PFAS
DL3 <- tibble(
  pfas = pfas3,
  mrl  = c(0.09, 0.01, 0.03, 0.02, 0.02, 0.04)
) %>% 
  mutate(
    "mrlrt2" = mrl / sqrt(2)) %>% 
  select(-mrl)

DL5 <- tibble(
  pfas = pfas5,
  mrl = c(0.004, 0.004, 0.005, 0.003, 0.004, 0.003, 0.005, 0.003, 0.003, 0.005,
           0.005, 0.003, 0.003, 0.005, 0.002, 0.02, 0.003, 0.004, 0.003, 0.003,
           0.003, 0.003, 0.004, 0.003, 0.002, 0.005, 0.006, 0.008, 0.007)
) %>% 
  mutate(
    "mrlrt2" = mrl / sqrt(2))%>% 
  select(-mrl)



## Impute mrl/√2 for NAs
ucmr3 <- ucmr3 %>%  
  left_join(
    DL3, by = c("Contaminant"="pfas")) %>%
  mutate(
    na = is.na(AnalyticalResultValue),
    AnalyticalResultValue = (if_else(
      na, mrlrt2, AnalyticalResultValue))) 

ucmr5 <- ucmr5 %>%  
  left_join(
    DL5, by = c("Contaminant"="pfas")) %>%
  mutate(
    na = is.na(AnalyticalResultValue),
    AnalyticalResultValue = (if_else(
      na, mrlrt2, AnalyticalResultValue))) 

## check if impute correct - n values near "mcl/√2" for each PFAS, compare to "nas"
###!!! fix issues !!!!
imp_check3 <- ucmr3%>% 
  count(
    Contaminant, near(AnalyticalResultValue, mrlrt2)) %>% 
  left_join(
    check3, 
    by = c("Contaminant","na"), suffix = c("_orig","_imp")) %>% 
  mutate(
    match = n_orig == n_imp
  )

imp_check5 <- ucmr5 %>% 
  count(
  Contaminant, near(AnalyticalResultValue, mrlrt2))


# Average values for each facility 


  

  
  







