# import packages
library(tidyverse)
library(rvest)
library(lubridate)

# scrape show info
datalist = list()
n = 1
for (i in 1:7) {
  Sys.sleep(1)
  url = paste('https://www.imdb.com/title/tt1826940/episodes?season=', i , sep = '')
  page = read_html(url)
  episodes = page %>% html_node('.list') %>% html_nodes('.info')
  for (j in 1:length(episodes)) {
    season = i
    title = episodes[j] %>% html_node('a') %>% html_text()
    airdate = episodes[j] %>% html_node('.airdate') %>% html_text()
    rating = episodes[j] %>% html_node('.ipl-rating-star.small .ipl-rating-star__rating') %>% html_text()
    votes = episodes[j] %>% html_node('.ipl-rating-star__total-votes') %>% html_text()
    description = episodes[j] %>% html_node('.item_description') %>% html_text()
    print(paste(title, airdate, rating, votes, description, sep = ' '))
    row = c(season, title, airdate, rating, votes, description)
    datalist[[n]] = row
    n = n +1
  }
}
raw = do.call(rbind, datalist)

# clean
new_girl = raw %>% as_tibble() %>%
  rename(season = V1, title = V2, airdate = V3, rating = V4, votes = V5, description = V6) %>% 
  mutate(airdate = str_trim(airdate), description = str_trim(description)) %>%
  mutate(airdate = dmy(airdate), rating = as.numeric(rating)) %>%
  mutate(votes = gsub("\\(","", votes)) %>% mutate(votes = gsub("\\)","", votes)) %>% mutate(votes = as.numeric(gsub(",","", votes)))

# export
write_csv(new_girl, 'new-girl-imdb-episodes.csv')
