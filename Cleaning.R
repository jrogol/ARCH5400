#### SQL Query ####
require(RPostgreSQL)

# Connect to the database
con = dbConnect(dbDriver("PostgreSQL"), user = 'jamesrogol',
                host = 'localhost',
                port = 5432,
                dbname = 'chicago')

# Query the tweets
tweets = dbGetQuery(con,"
           SELECT top_topic, tz, text, user_handle, name, r.user_id
           FROM topic_assignment a RIGHT JOIN 
                (recast c JOIN languages l ON c.user_lang = l.code)
                r ON a.user_id = r.user_id;
           ")

# disconnect
dbDisconnect(con)


#### Data Wrangling ####
library(tidyverse)
library(timeDate)
library(lubridate)
library(stringr)
library(readr)

## Round to nearest minute, create language/Topics
clean <- tweets %>% 
  mutate(time = round_date(ymd_hms(tz,tz = "America/Chicago"), unit = "minute"),
         lang.topic = ifelse(is.na(top_topic), 
                             as.character(name),
                             paste("Topic",str_extract(top_topic,"[0-9]+"),
                                   "-",name)))
# Find the number of unique users
unique.users <- clean %>%
  group_by(lang.topic) %>%
  filter(!is.na(lang.topic)) %>%
  mutate(users = length(unique(user_id))) %>%
  select(lang.topic, users) %>%
  unique %>%
  arrange(desc(users))

top_topics <- clean %>% 
  group_by(lang.topic) %>% 
  count %>%
  arrange(desc(n))

# Summarize the data by tweets per topic, by minute
tweets_by_time <- clean %>%
  left_join(unique.users) %>%
  group_by(time, lang.topic) %>%
  mutate(tpu = n()/users, tweets = n()) %>%
  select(time, lang.topic, tweets, tpu) %>%
  filter(lang.topic %in% top_topics$lang.topic[1:20])

write_csv(tweets_by_time, "Data/tweets_by_time.csv")
#### Blog Wrangling ####
library(readr)
library(dplyr)
library(lubridate)

blog <- read_csv("Data Collection/all_blog.csv")

blog.clean <- blog %>%
  mutate(time = round_date(ymd_hms(timestamp,tz = "America/New_York"), unit = "minute"),
         cst = with_tz(time, tz="America/Chicago")) %>% 
  select(cst, header, text) %>%
  mutate(cst = as.POSIXct(cst))

write_csv(blog.clean, "Data/blog_clean.csv")



#### Box Score Wrangling ####
library(readr)

keyevents <- read_csv("Data Collection/blog.csv")
key.clean <- keyevents %>%
  mutate(time = round_date(ymd_hms(timestamp,tz = "America/New_York"), unit = "minute"),
                              cst = with_tz(time, tz="America/Chicago")) %>% 
  select(cst, header, text) %>%
  mutate(cst = as.POSIXct(cst))

write_tsv(key.clean,"Data/clean_key.tsv")

box_score <- read_csv("Data Collection/G7_box.csv")
names(box_score) <- gsub("@","at",names(box_score))
names(box_score) <- gsub("[(].+[)]","",names(box_score))


clean.box <- box_score %>%
  select(Inn, Score, atBat, Batter, Pitcher, wWPA, wWE, `Play Description`) %>%
  mutate(Batter = gsub("[?]"," ", Batter),
         Pitcher = gsub("[?]"," ", Pitcher),
         Inn = gsub("t","Top ", Inn),
         Inn = gsub("b","Bottom ", Inn),
         wWPA = as.numeric(sub("%","",wWPA))
         )

write_csv(clean.box,"Data/clean_box.csv")
