# Example 100-meter dash data

# Source: 
# https://en.wikipedia.org/wiki/Athletics_at_the_2016_Summer_Olympics_%E2%80%93_Men%27s_100_metres#Final

# Authors: Sara Altman, Bill Behrman
# Version: 2019-12-12

# Libraries
library(tidyverse)
library(rvest)

# Parameters
  # URL for data
url_data <-
  "https://en.wikipedia.org/wiki/Athletics_at_the_2016_Summer_Olympics_%E2%80%93_Men%27s_100_metres"
  # CSS selector
css_selector <- "#mw-content-text > div > table:nth-child(61)"
#===============================================================================

example_sprint <-
  url_data %>%
  read_html() %>%
  html_node(css = css_selector) %>%
  html_table() %>%
  as_tibble() %>%
  rename_all(str_to_lower) %>%
  filter(!is.na(lane)) %>% 
  mutate_at(vars(reaction, time), as.double) %>%
  mutate(rank = min_rank(time)) %>% 
  select(-notes) 

usethis::use_data(example_sprint, overwrite = TRUE)
