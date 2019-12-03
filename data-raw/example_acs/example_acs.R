# Example 5-year ACS data

# Author: Sara Altman, Bill Behrman
# Version: 2019-12-02

# Libraries
library(tidyverse)
library(tidycensus)

# Parameters
YEAR <- 2017
variables <- 
  c(
    "pop_housed" = "B25008_001", 
    "pop_renter" = "B25008_003",
    "median_rent" = "B25064_001"
  )

states <- c("Alabama", "Georgia")

#===============================================================================

df <- 
  get_acs(
    geography = "state", 
    variables = variables, 
    year = YEAR
  ) %>% 
  rename_all(str_to_lower) %>% 
  rename(error = moe)

example_acs_1 <- 
  df %>% 
  select(geoid, name, variable, estimate)

example_acs_3 <- 
  df %>% 
  filter(
    name %in% states,
    variable %in% c("pop_renter", "median_rent")
  )

example_acs_2 <- 
  example_acs_3 %>% 
  pivot_longer(
    cols = c(estimate, error), 
    names_to = "measure", 
    values_to = "value"
  )

example_acs_4 <- 
  df %>% 
  filter(name %in% states)

usethis::use_data(example_acs_1, overwrite = TRUE)
usethis::use_data(example_acs_2, overwrite = TRUE)
usethis::use_data(example_acs_3, overwrite = TRUE)
usethis::use_data(example_acs_4, overwrite = TRUE)
