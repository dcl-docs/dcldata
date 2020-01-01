# Download Gapminder country life expectancy data.

# Documentation
# https://www.gapminder.org/data/documentation/gd004/

# Source
# https://github.com/Gapminder-Indicators/lex/raw/master/lex-by-gapminder.xlsx

# Author: Bill Behrman, Sara Altman
# Version: 2020-01-01

# Libraries
library(tidyverse)
library(readxl)

# Parameters
  # URL of Excel spreadsheet with life expectancy data
url_life_expectancy <-
  "https://github.com/Gapminder-Indicators/lex/raw/master/lex-by-gapminder.xlsx"
  # Sheet with country life expectancy data
sheet <- "countries_and_territories"
  # Temporary directory
dir_tmp <- str_c("/tmp/", Sys.time() %>% as.integer(), "/")
  # Temporary file
file_tmp <- "life_expectancy.xlsx"

#===============================================================================

path_temp <- fs::file_temp(ext = ".xlsx")
if (download.file(url = url_life_expectancy, destfile = path_temp)) {
  stop("Error: Failed to download Excel spreadsheet")
}

# Read in and tidy data
gm_life_expectancy <- 
  read_excel(path_temp, sheet = sheet) %>% 
  select(-starts_with("indicator")) %>% 
  select(iso_a3 = geo, name = geo.name, everything()) %>% 
  pivot_longer(
    cols = -c(iso_a3, name), 
    names_to = "year", 
    names_ptypes = list(year = integer()),
    values_to = "life_expectancy",
    values_drop_na = TRUE
  ) %>% 
  mutate_if(is.character, str_trim) %>%
  filter(str_length(iso_a3) == 3) %>% 
  mutate(iso_a3 = recode(iso_a3, hos = "vat")) %>% 
  arrange(name, year)

# Remove temporary directory
if (unlink(path_temp, recursive = TRUE, force = TRUE)) {
  print("Error: Remove temporary directory failed")
}

# If no value for Taiwan in 2017, use value for 2016

if (!any(gm_life_expectancy$iso_a3 == "twn" & gm_life_expectancy$year == 2017)) {
  gm_life_expectancy <- 
    gm_life_expectancy %>% 
    add_row(
      iso_a3 = "twn",
      name = "Taiwan",
      year = 2017,
      life_expectancy = 
        gm_life_expectancy %>% 
        filter(iso_a3 == "twn", year == 2016) %>% 
        pull(life_expectancy)
    ) %>% 
    arrange(name, year)
}

# Check data
stopifnot(
  sum(is.na(gm_life_expectancy)) == 0,
  all(str_length(gm_life_expectancy$iso_a3) == 3),
  n_distinct(gm_life_expectancy$iso_a3) == n_distinct(gm_life_expectancy$name),
  gm_life_expectancy$year >= 1800,
  gm_life_expectancy$year <= 2100,
  gm_life_expectancy$life_expectancy > 0,
  gm_life_expectancy$life_expectancy < 100
)

usethis::use_data(gm_life_expectancy, overwrite = TRUE)

