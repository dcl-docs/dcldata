# Download Gapminder country data.

# Documentation
# https://www.gapminder.org/data/geo/

# Source
# http://gapm.io/dl_geo

# Author: Bill Behrman, Sara Altman
# Version: 2019-12-30

# Libraries
library(tidyverse)
library(readxl)

# Parameters
  # URL of Excel spreadsheet with life expectancy data
url_life_expectancy <- "http://gapm.io/dl_geo"
  # Sheet with country life expectancy data
sheet <- "list-of-countries-etc"
  # Temporary directory
dir_tmp <- str_c("/tmp/", Sys.time() %>% as.integer(), "/")
  # Temporary file
file_tmp <- "countries.xlsx"
  # Output file
file_out <- "../data/countries.rds"

#===============================================================================

# Create temp directory
if (!file.exists(dir_tmp)) {
  dir.create(dir_tmp, recursive = TRUE)
}

# Download Excel spreadsheet
path <- str_c(dir_tmp, file_tmp)
if (download.file(url = url_life_expectancy, destfile = path)) {
  stop("Error: Failed to download Excel spreadsheet")
}

# Read in and tidy data
gm_countries <- 
  read_excel(path, sheet = sheet) %>% 
  select(
    iso_a3 = geo,
    name,
    region_gm4 = four_regions,
    region_gm6 = six_regions,
    region_gm8 = eight_regions,
    region_wb = "World bank region",
    oecd_g77 = members_oecd_g77,
    un_admission = "UN member since",
    income_wb_2017 = "World bank, 4 income groups 2017"
  ) %>% 
  mutate_if(is.character, str_trim) %>%
  filter(str_length(iso_a3) == 3) %>% 
  mutate(
    iso_a3 = recode(iso_a3, hos = "vat"),
    region_wb = str_replace(region_wb, "&", "and"),
    oecd_g77 = recode(oecd_g77, others = NA_character_),
    un_status =
      case_when(
        !is.na(un_admission)        ~ "member",
        iso_a3 %in% c("pse", "vat") ~ "observer",
        TRUE                        ~ "non-member"
      ),
    un_admission = lubridate::as_date(un_admission)
  ) %>% 
  select(iso_a3:oecd_g77, un_status, un_admission, income_wb_2017) %>% 
  arrange(name)

# Remove temporary directory
if (unlink(dir_tmp, recursive = TRUE, force = TRUE)) {
  print("Error: Remove temporary directory failed")
}

# Check data
stopifnot(
  all(str_length(countries$iso_a3) == 3),
  n_distinct(countries$iso_a3) == nrow(df),
  n_distinct(countries$name) == nrow(df),
  n_distinct(countries$region_gm4) == 4,
  n_distinct(countries$region_gm6) == 6,
  n_distinct(countries$region_gm8) == 8,
  all(countries$oecd_g77 %in% c("oecd", "g77", NA)),
  all(countries$un_status %in% c("member", "observer", "non-member"))
)

usethis::use_data(gm_countries, overwrite = TRUE)

