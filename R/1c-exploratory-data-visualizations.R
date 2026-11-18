################################################################################
# Organization: WHO LAB
# Project: K01 Aim 1: Surface level PFAS exposure map
# Author(s): Jordan Fischbach, Claude
# Purpose:  Exploratory data visualizations
################################################################################
source(here::here("R/0-config.R")) 
################################################################################
# Load relevant raw and intermediate data sets  --------------------------------
ucmr3_averaged_values <- fread(here("data/intermediate/ucmr3_averaged_values"))
ucmr5_averaged_values <- fread(here("data/intermediate/ucmr5_averaged_values"))



# Plot distribution of PFAS [ ] in UCMR --------------------------------------
## UCMR 3
pdf(file = here("figures/Exploratory_data_figures/ucmr3_PFAS_distribution.pdf"))

ggplot(ucmr3_averaged_values, aes(x = mean)) +
  geom_histogram(bins = 30) +
  scale_x_log10() +
  facet_wrap(~ Contaminant, scales = "free_y") +
  labs(
    title = "UCMR 3 - PFAS [ ]",
    x = "Mean concentration (µg/L, log scale)",
    y = "Number of PWS"
  ) +
  theme_minimal()

dev.off()

## UCMR 5
pdf(file = here("figures/Exploratory_data_figures/ucmr5_PFAS_distribution.pdf"))

ggplot(ucmr5_averaged_values, aes(x = mean)) +
  geom_histogram(bins = 30) +
  scale_x_log10() +
  facet_wrap(~ Contaminant, scales = "free_y") +
  labs(
    title = "UCMR 5 - PFAS [ ]",
    x = "Mean concentration (µg/L, log scale)",
    y = "Number of PWS"
  ) +
  theme_minimal()

dev.off()

