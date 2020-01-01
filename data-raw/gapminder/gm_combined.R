# Gapminder data for country name, region_gm4, population, GDP per capita, and
# life expectancy every `interval` years from `year_begin` to `year_end`.

# Author: Bill Behrman, Sara Altman
# Version: 2020-01-01

# Libraries
library(tidyverse)

# Parameters
data_countries <- "gm_countries"
data_gdp <- "gm_gdp"
data_life_expectancy <- "gm_life_expectancy"
data_population <- "gm_population"
  # Year range
year_begin <- 1950
year_end <- 2015
  # Year interval
interval <- 5

#===============================================================================

# Read in data
countries <- get(data_countries)
gdp <- get(data_gdp)
life_expectancy <- get(data_life_expectancy)
population <- get(data_population)

# Combine data and write out
gm_combined <-
  countries %>% 
  filter(un_status == "member") %>% 
  select(iso_a3, name, region = region_gm4) %>% 
  mutate_at(vars(region), str_to_title) %>% 
  left_join(population %>% select(-name), by = "iso_a3") %>% 
  left_join(gdp %>% select(-name), by = c("iso_a3", "year")) %>% 
  left_join(life_expectancy %>% select(-name), by = c("iso_a3", "year")) %>% 
  filter(year >= year_begin, year <= year_end, year %% interval == 0) %>% 
  group_by(iso_a3) %>% 
  filter(
    all(!is.na(population)) &
      all(!is.na(gdp_per_capita)) &
      all(!is.na(life_expectancy))
  ) %>% 
  ungroup() 

usethis::use_data(gm_combined, overwrite = TRUE)


