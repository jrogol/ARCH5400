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

# Summarize the data by tweets per topic, by minute
tweets_by_time <- clean %>%
  left_join(unique.users) %>%
  group_by(time, lang.topic) %>%
  mutate(tpu = n()/users, tweets = n()) %>%
  select(time, lang.topic, tweets, tpu)

