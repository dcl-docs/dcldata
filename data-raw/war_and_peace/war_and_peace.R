# Rank and frequency for all words in Tolstoy's War and Peace. 

# Source: http://www.gutenberg.org/

# Authors: Sara Altman, Bill Behrman
# Version: 2019-12-31

# Libraries
library(tidyverse)
library(gutenbergr)
library(tidytext)

# Parameters
  # Ebook number from www.gutenberg.org
war_and_peace_id <- 2600
#===============================================================================

war_and_peace <-
  gutenberg_download(war_and_peace_id) %>% 
  unnest_tokens(word, text) %>% 
  count(word, sort = TRUE, name = "freq") %>% 
  mutate(rank = min_rank(desc(freq)))

usethis::use_data(war_and_peace, overwrite = TRUE)

