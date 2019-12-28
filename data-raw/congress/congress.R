# Data on Congress members' ages

# Source: https://github.com/unitedstates/congress-legislators

# Author: Sara Altman, Bill Behrman
# Version: 2019-12-28

# Libraries
library(tidyverse)
library(jsonlite)
library(lubridate)

# Parameters
  # URL for historical data
url_current_data <- 
  "https://theunitedstates.io/congress-legislators/legislators-current.json"
  # URL for current data
url_historical_data <-
  "https://theunitedstates.io/congress-legislators/legislators-historical.json"
  # US Census divisions
  # Source: https://en.wikipedia.org/wiki/List_of_regions_of_the_United_States#Census_Bureau-designated_regions_and_divisions
divisions <-
  list(
    `East North Central` = c("IL", "IN", "MI", "OH", "WI"),
    `East South Central` = c("AL", "KY", "MS", "TN"),
    `Middle Atlantic` =	c("NJ", "NY", "PA"),
    `Mountain` = c("AZ", "CO", "ID", "MT", "NM", "NV", "UT", "WY"),
    `New England` = c("CT", "MA", "ME", "NH", "RI", "VT"),
    `Pacific` =	c("AK", "CA", "HI", "OR", "WA"),
    `South Atlantic` = c("DC", "DE", "FL", "GA", "MD", "NC", "SC", "VA", "WV"),
    `West North Central` = c("IA", "KS", "MN", "MO", "ND", "NE", "SD"),
    `West South Central` = c("AR", "LA", "OK", "TX")
  ) %>% 
  enframe(name = "division", value = "state") %>% 
  unnest()
  
  # Date to use to determine Congress membership. Most members started on Jan. 3rd,
  # except for Rick Scott (FL) and Walter Jones (NC).
DATE <- ymd("2019-01-08")
#===============================================================================

congress_pull <- function(category, var, default = NA) {
  all %>% 
    map(category) %>% 
    map_chr(var, .default = default)
}

all <-
  list(
    read_json(url_historical_data),
    read_json(url_current_data)
  ) %>%
  purrr::flatten()

v <-
  tibble(
    id = congress_pull("id", "bioguide"),
    first = congress_pull("name", "first"),
    last = congress_pull("name", "last"),
    birthday = congress_pull("bio", "birthday") %>% as_date(),
    gender = congress_pull("bio", "gender"),
    terms_data = map(all, "terms")
  ) %>% 
  unnest(cols = terms_data) %>% 
  mutate(
    start_date = map_chr(terms_data, "start", .default = NA) %>% as_date(),
    end_date = map_chr(terms_data, "end", .default = NA) %>% as_date(),
    party = map_chr(terms_data, "party", .default = NA),
    chamber = map_chr(terms_data, "type", .default = NA),
    state = map_chr(terms_data, "state", .default = NA)
  ) %>%  
  select(-terms_data) %>% 
  mutate(
    name = str_c(first, last, sep = " "),
    age = round(decimal_date(DATE) - decimal_date(birthday), 2),
    chamber = 
      recode(
        chamber, 
        rep = "House", 
        sen = "Senate", 
        .default = NA_character_
      ),
    party = fct_lump(party, n = 2) %>% as.character()
  ) %>% 
  left_join(divisions, by = "state") 

congress <-
  v %>% 
  filter(
    start_date <= DATE,
    end_date > DATE,
    !is.na(division) # exclude non-voting members from territories
  ) %>% 
  select(name, state, division, chamber, party, age, gender) %>% 
  arrange(state, division, chamber, party) 

usethis::use_data(congress, overwrite = TRUE)
