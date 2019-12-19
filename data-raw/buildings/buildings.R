# Building height data

# Author: Sara Altman, Bill Behrman
# Version: 2019-12-18

# Libraries
library(tidyverse)
library(rvest)

# Parameters
  # URL 
url_data <-
  "https://en.wikipedia.org/wiki/List_of_tallest_buildings"
  # CSS selector
css_selector <- "#mw-content-text > div > table:nth-child(22)"

#===============================================================================

buildings <-
  url_data %>%
  read_html() %>%
  html_node(css = css_selector) %>%
  html_table(fill = TRUE) %>%
  as_tibble(.name_repair = "unique") %>% 
  janitor::row_to_names(row_number = 1) %>% 
  rename_all(str_to_lower) %>% 
  rename(height = `height[9]`, building = name) %>% 
  mutate(
    height = str_remove_all(height, "[:punct:]") %>% as.double()
  ) %>% 
  select(building, city, country, height, floors, year)

usethis::use_data(buildings, overwrite = TRUE)
