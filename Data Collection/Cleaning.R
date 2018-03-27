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
  mutate(cst = round_date(ymd_hms(tz,tz = "America/Chicago"), unit = "minute"),
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

# Filter to the date range

game_tweets <- clean %>% mutate(cst = cst - hrs(4)) %>%
  filter(cst >= strptime(start, tz = "America/Chicago", "%Y-%m-%dT%H:%M") &
           cst < strptime(end, tz = "America/Chicago", "%Y-%m-%dT%H:%M"))


top_topics <- game_tweets %>% 
  group_by(lang.topic) %>% 
  count %>%
  arrange(desc(n))

# Summarize the data by tweets per topic, by minute
tweets_by_time <- game_tweets %>%
  ungroup %>%
  group_by(cst, lang.topic) %>%
  tally %>% rename(tweets = n) %>%
  left_join(unique.users) %>% 
  mutate(tpu = tweets/users) %>%
  select(cst, lang.topic, tweets, tpu) %>%
  filter(lang.topic %in% top_topics$lang.topic[1:10]) %>%
  ungroup %>% mutate(cst = as.POSIXct(cst, tz= "America/Chicago"))

write_csv(tweets_by_time, "Data/tweets_by_time2.csv")
#### Blog Wrangling ####
library(readr)
library(dplyr)
library(lubridate)

blog <- read_csv("Data Collection/all_blog.csv")

blog.clean <- blog %>%
  mutate(time = round_date(ymd_hms(timestamp,tz = "America/New_York"), unit = "minute"),
         cst = with_tz(cst, tz="America/Chicago"),
         text = gsub("\n"," ", text)) %>% 
  select(cst, header, text) %>%
  mutate(cst = as.POSIXct(cst, tz="America/Chicago")) 

write_csv(blog.clean, "Data/blog_clean.csv")



#### Box Score Wrangling ####
library(readr)

keyevents <- read_csv("Data Collection/blog.csv")
key.clean <- keyevents %>%
  mutate(cst = round_date(ymd_hms(timestamp,tz = "America/New_York"), unit = "minute"),
                              cst = with_tz(cst, tz="America/Chicago"),
         text = gsub("\n"," ", text)) %>% 
  select(cst, header, text) %>%
  mutate(cst = as.POSIXct(cst, tz="America/Chicago"))

write_csv(key.clean,"Data/clean_key.csv")

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

#### Join Blog with Total Tally ####

# Find all users
all_users <- unique.users %>%
  # filter(lang.topic %in% top_topics$lang.topic[1:10]) %>% 
  ungroup %>% mutate(total = sum(users))


# Create summary of all tweets
total_tweets <- game_tweets %>%
  left_join(all_users) %>%
  # filter(lang.topic %in% top_topics$lang.topic[1:10]) %>%
  group_by(cst) %>% summarise(tweets = n(), tpu = n()/max(total))

 

total_blog <- total_tweets %>%
  left_join(blog.clean, by = c("cst" = "cst")) %>% arrange(cst)

# Replace NA's with empty strings
total_blog[is.na(total_blog)] <- ""

write_csv(total_blog,"Data/total_blog2.csv")
write_csv(total_blog%>% filter(!is.na(header)) %>% head(10),"Data/test.csv")

