################################################################################
# Organization - WHO LAB
# Project - K01 Aim 1: Surface level PFAS exposure map
# Jordan Fischbach, Dr. Cindy Hu, Claude
# This file imports UCMR3 and UCMR5 data and conducts manipulation, cleaning, and characterization
################################################################################
source(here::here("R/0-config.R")) 
################################################################################
# Load relevant raw and intermediate data sets (see 0-config)
ucmr3 <- fread(here("data", "intermediate", "ucmr3_pfas_raw"))
ucmr5 <- fread(here("data", "intermediate", "ucmr5_pfas_raw"))
################################################################################
# Investigate UCMR and PWS data 
################################################################################
# INSIGHTS FROM CODE BELOW
## Does each PWS facility have a reading each year for each PFAS? A: No, majority sampled over 12 month period.
## What is the % of detection? A: ucmr3 - 0.52%; ucmr5 - 3.03% 
## Differences in PWSID names measuring in 3 vs 5? A: 4438 shared PWSID names in both, 482 unique to 3, 5874 unique to 5

# UCMR3 ####
## Filter by individual PWS facility for unique readings of PFAS per year
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
nrow(outlier3)

#### n NAs 
nas_ucmr3 <- ucmr3 %>% 
  group_by(Contaminant) %>% 
  count(is.na(AnalyticalResultValue)) %>% 
  rename(is_na = "is.na(AnalyticalResultValue)")
na <- sum(nas_ucmr3$n[nas_ucmr3$is_na == TRUE])
t <-sum(nas_ucmr3$n)

na/t # % of nas in ucmr3

# UCMR5 ####
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
nrow(outlier5)

#### n NAs 
nas_ucmr5 <- ucmr5 %>% 
  group_by(Contaminant) %>% 
  count(is.na(AnalyticalResultValue)) %>% 
  rename(is_na = "is.na(AnalyticalResultValue)")
na <- sum(nas_ucmr5$n[nas_ucmr5$is_na == TRUE])
t <-sum(nas_ucmr5$n)
na/t # % nas in ucmr5

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
# Compare UCMR3 and UCMR 5 ####
# Comparison of PWSID in each data set
ucmr3 <- fread(here("data", "intermediate", "ucmr3_pfas_raw")) # @cindy ease of use for me, is this best practice?
ucmr5 <- fread(here("data", "intermediate", "ucmr5_pfas_raw"))

pws3 <- ucmr3 %>% 
  distinct(PWSID)
pws5 <- ucmr5 %>% 
  distinct(PWSID)
pws_both <- pws3 %>% 
  semi_join(pws5, by = "PWSID")
pws_only3 <- pws3 %>%
  anti_join(pws5, by = "PWSID")
pws_only5 <- pws5 %>% 
  anti_join(pws3, by ="PWSID")

#### Compare PWS data and UCMR data
pws_all_us <- pws %>% 
  distinct(PWSID)
pws3_all_both <- pws3 %>% 
  semi_join(pws_all_us, by ="PWSID")
pws3_all_only3 <- pws3 %>% 
  anti_join(pws_all_us, by = "PWSID")
pws5_all_both <- pws5 %>% 
  semi_join(pws_all_us, by = "PWSID")
pws5_all_only5 <- pws5 %>% 
  anti_join(pws_all_us, by = "PWSID")

fwrite(pws_all_us, here("data", "intermediate", "epa_all_pwsids"))
fwrite(pws3_all_only3, here("data", "intermediate", "ucmr3_pwsid_name_different"))
fwrite(pws5_all_only5, here("data", "intermediate", "ucmr5_pwsid_name_different"))
  

################################################################################
# Select and clean data - filter columns and  impute for NAs
################################################################################
# Select relevant columns ####
ucmr3_select <- ucmr3 %>% 
  select(
    PWSID, Contaminant, MRL, AnalyticalResultValue)
ucmr5_select <- ucmr5 %>% 
  select(
    PWSID, Contaminant, MRL, AnalyticalResultValue) 

# Impute NA values ####
## Imputed as DL/sqrt 2 (Hu 2021 - Table 1)

## 1. Create table of MRL/√2 values for each PFAS
DL3 <- tibble(
  pfas = pfas3,
  mrl  = c(0.09, 0.01, 0.03, 0.02, 0.02, 0.04)
) %>% 
  mutate(
    "mrl_sqrt2" = mrl / sqrt(2)) %>% 
  select(-mrl)

DL5 <- tibble(
  pfas = pfas5,
  mrl = c(0.004, 0.004, 0.005, 0.003, 0.004, 0.003, 0.005, 0.003, 0.003, 0.005,
           0.005, 0.003, 0.003, 0.005, 0.002, 0.02, 0.003, 0.004, 0.003, 0.003,
           0.003, 0.003, 0.004, 0.003, 0.002, 0.005, 0.006, 0.008, 0.007)
) %>% 
  mutate(
    "mrl_sqrt2" = mrl / sqrt(2)) %>% 
  select(-mrl)

## 2. Impute mrl/√2 for NAs
ucmr3_select <- ucmr3_select %>%  
  left_join(
    DL3, by = c("Contaminant"="pfas")) %>%
  mutate(
    na = is.na(AnalyticalResultValue),
    AnalyticalResultValue = (if_else(na, mrl_sqrt2, AnalyticalResultValue))) 

ucmr5_select <- ucmr5_select %>%  
  left_join(
    DL5, by = c("Contaminant"="pfas")) %>%
  mutate(
    na = is.na(AnalyticalResultValue),
    AnalyticalResultValue = (if_else(na, mrl_sqrt2, AnalyticalResultValue))) 

## 3. check if impute correct
# N values near "mcl/√2" for each PFAS, compare to "nas"
imp_check3 <- ucmr3_select%>% 
  count(
    Contaminant, detect = near(AnalyticalResultValue, mrl_sqrt2))
imp_check5 <- ucmr5_select %>% 
  count(
    Contaminant, detect = near(AnalyticalResultValue, mrl_sqrt2))

# Average values for each facility ####
ucmr3_averaged_values <- ucmr3_select %>% 
  group_by(PWSID, Contaminant) %>% 
  summarise(
    mean = mean(AnalyticalResultValue),
    na_count = sum(na),
    .groups = "drop"
  ) 
fwrite(ucmr3_averaged_values, here("data", "intermediate", "ucmr3_averaged_pfas_values"))

ucmr5_averaged_values <- ucmr5_select %>% 
  group_by(PWSID, Contaminant) %>% 
  summarise(
    mean = mean(AnalyticalResultValue),
    na_count = sum(na),
    .groups = "drop"
  )
fwrite(ucmr5_averaged_values, here("data", "intermediate", "ucmr5_averaged_pfas_values"))
  

  

  
  







