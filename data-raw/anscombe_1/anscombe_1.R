# Modified Anscombe's quartet data

# Author: Sara Altman, Bill Behrman
# Version: 2019-11-27

# Libraries
library(tidyverse)

# Parameters
file_anscombe_1 <- here::here("data-raw/anscombe_1/anscombe_1.csv")

#===============================================================================

anscombe_1 <-
  read_csv(file_anscombe_1, col_types = cols(.default = col_double()))

usethis::use_data(anscombe_1, overwrite = TRUE)

anscombe_1_outlier <-
  anscombe_1 %>%
  add_row(x_1 = 20, y = 0.15)

usethis::use_data(anscombe_1_outlier, overwrite = TRUE)
