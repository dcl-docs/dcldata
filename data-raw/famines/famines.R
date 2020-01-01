# Famines data from Our World in Data 

# Source: https://ourworldindata.org/famines#the-our-world-in-data-dataset-of-famines

# Author: Sara Altman, Bill Behrman
# Version: 2020-01-01

# Libraries
library(tidyverse)
library(rvest)

# Parameters
  # URL with table
url_page <- "https://ourworldindata.org/famines"
  # CSS selector
famines_css_selector <- "#tablepress-73"
  # case_when() data to supply missing regions
recode_region <-
  quo(
    case_when(
      is.na(region) & str_detect(country, "USSR")   ~ "europe",
      is.na(region) & str_detect(country, "Africa") ~ "africa",
      is.na(region) & str_detect(country, "Asia")   ~ "asia",
      is.na(region) & str_detect(country, "Syria")  ~ "asia",
      is.na(region) & str_detect(country, "Congo")  ~ "africa",
      country == "Persia"                           ~ "asia",
      TRUE                                          ~ region
    )
  )
 # Recoding for country names
country_recode <- 
  c(
    "S Africa" = "South Africa", 
    "USA" = "United States", 
    "Democratic Republic of Congo" = "Congo, Dem. Rep."
  )
#===============================================================================
# Removes parentheses from names; converts to lower case; uses _ instead of spaces
rename_convention <- function(col_name) {
  col_name %>% 
    str_to_lower() %>% 
    str_remove("\\s\\(.*") %>% 
    str_replace_all("\\s", "_")
}

countries <- 
  get("gm_countries")

famines <-
  read_html(url_page) %>%
  html_node(famines_css_selector) %>% 
  html_table() %>% 
  as_tibble() %>% 
  rename_all(rename_convention) %>% 
  separate(year, into = c("year_start", "year_end")) %>% 
  mutate(
    year_end =
      case_when(
        str_length(year_end) == 2 ~ 
          str_c(str_extract(year_start, "\\d{2}"), year_end),
        str_length(year_end) == 1 ~ 
          str_c(str_extract(year_start, "\\d{3}"), year_end),
        is.na(year_end)           ~ year_start,
        TRUE                      ~ year_end
      ),
    country = 
      str_remove_all(country, "\\s\\(.*") %>% recode(!!! country_recode)
  ) %>% 
  mutate_at(
    vars(year_start, year_end, contains("mortality")), 
    ~ str_remove_all(., "[,-]") %>% as.double()
  ) %>% 
  left_join(
    countries %>% select(iso_a3, name, region = region_gm4), 
    by = c("country" = "name")
  ) %>% 
  mutate(region = !! recode_region %>% str_to_title()) %>% 
  select(
    location = country,
    iso_a3, 
    region, 
    year_start, 
    year_end, 
    deaths_estimate = excess_mortality_midpoint
  ) 

usethis::use_data(famines, overwrite = TRUE)
