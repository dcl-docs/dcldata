# Gapminder country GDP per capita data.

# Documentation
# https://www.gapminder.org/data/documentation/gd001/

# Source
# https://github.com/Gapminder-Indicators/gdppc_cppp/raw/master/gdppc_cppp-by-gapminder.xlsx

# Author: Bill Behrman, Sara Altman
# Version: 2020-01-01

# Libraries
library(tidyverse)
library(readxl)

# Parameters
  # URL of Excel spreadsheet with GDP per capita data
url_gdp_per_capita <- 
  "https://github.com/Gapminder-Indicators/gdppc_cppp/raw/master/gdppc_cppp-by-gapminder.xlsx"
  # Sheet with country GDP per capita data
sheet <- "countries_and_territories"

#===============================================================================

# Download Excel spreadsheet
path_temp <- fs::file_temp(ext = ".xlsx")
if (download.file(url = url_gdp_per_capita, destfile = path_temp)) {
  stop("Error: Failed to download Excel spreadsheet")
}

# Read in and tidy data
gm_gdp <- 
  read_excel(path_temp, sheet = sheet) %>% 
  select(-starts_with("indicator")) %>% 
  select(iso_a3 = geo, name = geo.name, everything()) %>% 
  pivot_longer(
    cols = -c(iso_a3, name),
    names_to = "year",
    names_ptypes = list(year = integer()),
    values_to = "gdp_per_capita",
    values_drop_na = TRUE
  ) %>% 
  mutate_if(is.character, str_trim) %>%
  mutate(iso_a3 = recode(iso_a3, hos = "vat")) %>% 
  arrange(name, year)

# Remove temporary directory
if (unlink(path_temp, recursive = TRUE, force = TRUE)) {
  print("Error: Remove temporary directory failed")
}

# Check data
stopifnot(
  sum(is.na(gm_gdp)) == 0,
  all(str_length(gm_gdp$iso_a3) == 3),
  n_distinct(gm_gdp$iso_a3) == n_distinct(gm_gdp$name),
  gm_gdp$year >= 1800,
  gm_gdp$year <= 2040,
  gm_gdp$gdp_per_capita > 0,
  gm_gdp$gdp_per_capita < 2e5
)

usethis::use_data(gm_gdp, overwrite = TRUE)
