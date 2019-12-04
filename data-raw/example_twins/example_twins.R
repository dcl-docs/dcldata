# Example twin data

# Author: Sara Altman, Bill Behrman
# Version: 2019-12-03

# Libraries
library(tidyverse)

# Parameters
file_twins <- here::here("data-raw/example_twins/twins.csv")

#===============================================================================

example_twins <- 
  read_csv(file_twins) %>% 
  as_tibble()
attr(example_twins, "spec") <- NULL

usethis::use_data(example_twins, overwrite = TRUE)
