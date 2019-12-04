# Example migration data

# Authors: Sara Altman, Bill Behrman
# Version: 2019-12-03

# Libraries
library(tidyverse)

# Parameters
YEAR <- 2017
file_migration <- 
  fs::path(admin::dir_github(), "stanford-datalab/data/migration/answers.rds")
destinations <- c("Albania", "Bulgaria", "Romania")
origins <- vars("Afghanistan", "Canada", "India", "Japan", "South Africa")

#===============================================================================

example_migration <- 
  file_migration %>% 
  read_rds() %>% 
  pluck("q1") %>% 
  mutate_all(na_if, "..") %>% 
  filter(dest %in% destinations, year == YEAR) %>% 
  select(dest, !!! origins) %>% 
  arrange(dest)

usethis::use_data(example_migration, overwrite = TRUE)
