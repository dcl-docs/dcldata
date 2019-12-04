# Eagle nests data from US Fish and Wildlife

# Source: https://www.fws.gov/migratorybirds/pdf/management/EagleRuleRevisions-StatusReport.pdf#page=47&zoom=100,0,700

# Authors: Sara Altman, Bill Behrman
# Version: 2019-12-03

# Libraries
library(tidyverse)

# Parameters
  # File with eagle nest data
file_eagle_nests <- here::here("data-raw/example_eagle/eagle_nests.csv")

#===============================================================================

example_eagle_nests <- 
  read_csv(file_eagle_nests) %>% 
  as_tibble()
attr(example_eagle_nests, "spec") <- NULL

usethis::use_data(example_eagle_nests, overwrite = TRUE)

example_eagle_nests_tidy <-
  example_eagle_nests %>% 
  pivot_longer(cols = -region, names_to = "year", values_to = "num_nests")

usethis::use_data(example_eagle_nests_tidy, overwrite = TRUE)
