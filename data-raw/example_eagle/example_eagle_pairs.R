# Eagle pairs data from US Fish and Wildlife

# Authors: Sara Altman, Bill Behrman
# Version: 2019-12-21

# Libraries
library(tidyverse)
library(rvest)

# Parameters
url_data <- "https://www.fws.gov/midwest/eagle/NestingData/nos_state_tbl.html"
css_selector <- "#rightCol > table > tr:nth-child(2) > td > table"
years <- vars(`1997`:`2006`)

#===============================================================================

states <- 
  tibble(
    name = state.name,
    state_abbr = state.abb
  )

example_eagle_pairs <-
  url_data %>% 
  read_html() %>% 
  html_node(css = css_selector) %>% 
  html_table() %>% 
  as_tibble() %>% 
  janitor::row_to_names(row_number = 1) %>% 
  rename(state = nn) %>% 
  filter(state != "") %>%
  left_join(states, by = c("state" = "name")) %>% 
  mutate(state = str_replace(state, "Carolinaa", "Carolina")) %>% 
  mutate_at(
    vars(-starts_with("state")), 
    ~ na_if(., "") %>%
      str_replace(pattern = '(".*")|(b.*)', replacement = NA_character_) %>% 
      as.integer()
  ) %>% 
  select(state, state_abbr, !!! years)

usethis::use_data(example_eagle_pairs, overwrite = TRUE)
