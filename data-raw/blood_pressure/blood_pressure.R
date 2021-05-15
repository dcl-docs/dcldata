# Read in data from National Health and Nutrition Examination Survey and
# extract age and blood pressure data

# Source: https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Examination&CycleBeginYear=2017
# Codebooks:
#   Demographic data: https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DEMO_J.htm
#   Blood pressure data: https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/BPXO_J.htm

# Author: Bill Behrman
# Version: 2021-05-14

# Libraries
library(tidyverse)

# Parameters
  # URL for demographic data
url_demo <- "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DEMO_J.XPT"
  # URL for blood pressure data
url_bpxo <- "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/BPXO_J.XPT"

#===============================================================================

demo <- 
  url_demo %>% 
  haven::read_xpt() %>%
  rename_with(str_to_lower) %>% 
  select(seqn, ridageyr) %>% 
  drop_na() %>% 
  filter(ridageyr > 0)

bpxo <- 
  url_bpxo %>% 
  haven::read_xpt() %>% 
  rename_with(str_to_lower) %>% 
  select(seqn, starts_with("bpxosy")) %>% 
  drop_na(seqn) %>% 
  filter(!is.na(bpxosy1) | !is.na(bpxosy2) | !is.na(bpxosy3))

blood_pressure <- 
  demo %>% 
  inner_join(bpxo, by = "seqn") %>% 
  arrange(seqn)

usethis::use_data(blood_pressure, overwrite = TRUE)

