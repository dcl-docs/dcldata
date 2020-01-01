# Famines data from Our World in Data https://ourworldindata.org/famines

# Author: Sara Altman, Bill Behrman
# Version: 2019-12-31

# Libraries
library(tidyverse)
library(rvest)

# Parameters
  # URL with table
url_page <- "https://ourworldindata.org/famines"
  # CSS selector
famines_css_selector <-
  "body > main > article > div > div > div > section:nth-child(5) > div > table"
#===============================================================================
# Removes parentheses from names; converts to lower case; uses _ instead of spaces
rename_convention <- function(col_name) {
  col_name %>% 
    str_to_lower() %>% 
    str_remove("\\s\\(.*") %>% 
    str_replace_all("\\s", "_")
}

countries <- read_rds("../../gapminder/data/countries.rds")

famines <-
  read_html(url_page) %>%
  html_node(famines_css_selector) %>% 
  html_table() %>% 
  as_tibble() %>% 
  rename_all(rename_convention) %>% 
  separate(year, into = c("start", "end")) %>% 
  mutate(
    end =
      case_when(
        str_length(end) == 2 ~ str_c(str_extract(start, "\\d{2}"), end),
        str_length(end) == 1 ~ str_c(str_extract(start, "\\d{3}"), end),
        is.na(end)           ~ start,
        TRUE                 ~ end
      ),
    country = str_remove_all(country, "\\s\\(.*")
  ) %>% 
  mutate_at(
    vars(start, end, contains("mortality")), 
    ~ str_remove_all(., "[,-]") %>% as.double()
  ) %>% 
  select(
    start, 
    end, 
    name = country, 
    deaths_estimate = excess_mortality_midpoint
  ) %>% 
  left_join(
    countries %>% select(iso_a3, name, region = region_gm4), 
    by = "name"
  ) %>% 
  mutate(
    region = 
      case_when(
        is.na(region) & str_detect(name, "USSR")   ~ "europe",
        is.na(region) & str_detect(name, "Africa") ~ "africa",
        is.na(region) & str_detect(name, "Asia")   ~ "asia",
        is.na(region) & str_detect(name, "Syria")  ~ "asia",
        is.na(region) & str_detect(name, "Congo")  ~ "africa",
        name == "USA"                              ~ "americas",
        name == "Persia"                           ~ "asia",
        TRUE                                       ~ region
      )
  ) %>% 
  mutate(region = str_to_title(region)) %>% 
  select(name, iso_a3, region, start, end, deaths_estimate) %>% 
  write_rds("famines.rds")
