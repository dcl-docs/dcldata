# Download ACS data on non-English languages spoken at home for US and states

# Authors: Sara Altman, Bill Behrman
# Version: 2019-12-11

# Libraries
library(tidyverse)

# Parameters
  # API request template
request <- 
  "https://api.census.gov/data/2013/language?get=NAME,LANLABEL,EST,LAN39,LAN7&for={region}:*&LAN="

#===============================================================================

# Get languages for region
get_languages <- function(region) {
  str_glue(request) %>% 
    jsonlite::fromJSON() %>% 
    as_tibble() %>% 
    janitor::row_to_names(row_number = 1) %>% 
    rename_all(str_to_lower) %>%
    rename(
      language = lanlabel,
      speakers = est
    ) %>%
    mutate_at(vars(-name, -language), as.integer)
}

# Check US data
v <- get_languages("us")
v1 <-
  v %>%
  filter(language == "Speak a language other than English at home") %>%
  pull(speakers)
v2 <-
  v %>%
  filter(lan > 0, !is.na(speakers)) %>%
  pull(speakers) %>%
  sum()
v2 - v1

# Out of over 60 million speakers, the sum for the individual languages
# undercounts the total by only 265. Some of the languages have NAs, which may
# account for the discrepancy.

# Non-English languages spoken at home for the US
languages_us <-
  get_languages("us") %>%
  filter(lan > 0, speakers > 0) %>%
  select(language, speakers) %>%
  arrange(desc(speakers), language) 
# Check consistency of US and state data
v2 <-
  get_languages("state") %>%
  filter(state <= 56, lan > 0, speakers > 0) %>%
  pull(speakers) %>%
  sum()
v2 - v1

# Out of over 60 million speaker, the sum of the individual languages for the
# states undercounts the total for the US by 25882, or 0.04%. Again some of the
# languages for states have NAs, which may account for the discrepancy.

# Non-English languages spoken at home for the states
languages_states <-
  get_languages("state") %>%
  filter(state <= 56, lan > 0, speakers > 0) %>%
  select(state = name, language, speakers) %>%
  arrange(state, desc(speakers))

# # Top 20 languages (other than English and Spanish) spoken at home in Utah
# languages_utah <-
#   get_languages("state") %>%
#   filter(name == "Utah", language != "Spanish", lan > 0, speakers > 0) %>%
#   top_n(n = 20, wt = speakers) %>%
#   select(language, speakers) %>%
#   arrange(desc(speakers)) 

usethis::use_data(languages_us, overwrite = TRUE)
usethis::use_data(languages_states, overwrite = TRUE)
