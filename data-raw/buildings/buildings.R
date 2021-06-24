# Building height data

# Author: Sara Altman, Bill Behrman
# Version: 2021-06-24

# Libraries
library(tidyverse)
library(rvest)

# Parameters
  # URL 
url_data <- "https://en.wikipedia.org/wiki/List_of_tallest_buildings"
  # CSS selector
css_selector <- "#mw-content-text > div > table:nth-child(23)"

#===============================================================================

buildings <-
  url_data %>%
  read_html() %>%
  html_node(css = css_selector) %>%
  html_table(fill = TRUE) %>%
  janitor::row_to_names(row_number = 1) %>% 
  rename_with(str_to_lower) %>% 
  rename(building = name, height = ft) %>% 
  mutate(across(c(height, floors, year), parse_number)) %>% 
  select(building, city, country, height, floors, year)

usethis::use_data(buildings, overwrite = TRUE)
