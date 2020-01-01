# Gapminder country population data.

# Documentation
# https://www.gapminder.org/data/documentation/gd003/

# Source
# https://docs.google.com/spreadsheets/d/18Ep3s1S0cvlT1ovQG9KdipLEoQ1Ktz5LtTTQpDcWbX0/edit#gid=1668956939

# Author: Bill Behrman, Sara Altman
# Version: 2020-01-01

# Libraries
library(tidyverse)
library(googlesheets4)

# Parameters
  # URL of Google sheet with population data
id_population <- 
  "18Ep3s1S0cvlT1ovQG9KdipLEoQ1Ktz5LtTTQpDcWbX0"
  # Sheet with country population data
sheet <- "data-countries-etc-by-year"

#===============================================================================

# Read in data
gm_population <- 
  sheets_read(ss = id_population, sheet = sheet) %>% 
  rename(iso_a3 = geo, year = time) %>% 
  mutate(
    year = as.integer(year),
    iso_a3 = recode(iso_a3, hos = "vat")
  ) %>% 
  mutate_if(is.character, str_trim) %>% 
  arrange(name, year)

# Check data
stopifnot(
  sum(is.na(gm_population)) == 0,
  all(str_length(gm_population$iso_a3) == 3),
  n_distinct(gm_population$iso_a3) == n_distinct(gm_population$name),
  gm_population$year >= 1800,
  gm_population$year <= 2100,
  gm_population$population > 0,
  gm_population$population < 2e9
)

usethis::use_data(gm_population, overwrite = TRUE)

