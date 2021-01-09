##  Load the Corpus text data file
################################################################################
library(stringr)
library(tm)
library(ggplot2)
library(ngram)

# Files
twitter = "data/final/en_US/en_US.twitter.txt"
blogs = "data/final/en_US/en_US.blogs.txt"
news = "data/final/en_US/en_US.news.txt"

twitterRDS = "data/final/en_US/en_twitterRDS.rds"
blogsRDS = "data/final/en_US/en_blogsRDS.rds"
newsRDS = "data/final/en_US/en_newsRDS.rds"

en_3gramRDS = "data/final/en_US/en_3gramRDS.rds"
################################################################################

## Build the N-Gramsm, save as RDS file
################################################################################
tidyText <- function(file, tidyfile) {
  con <- file(file, open="r")
  lines <- readLines(con)
  close(con)
  
  lines <- tolower(lines)
  # split at all ".", "," and etc.
  lines <- unlist(strsplit(lines, "[.,:;!?(){}<>]+")) # 5398319 lines
  
  # replace all non-alphanumeric characters with a space at the beginning/end of a word.
  lines <- gsub("^[^a-z0-9]+|[^a-z0-9]+$", " ", lines) # at the beginning/end of a line
  lines <- gsub("[^a-z0-9]+\\s", " ", lines) # before space
  lines <- gsub("\\s[^a-z0-9]+", " ", lines) # after space
  lines <- gsub("\\s+", " ", lines) # remove mutiple spaces
  lines <- str_trim(lines) # remove spaces at the beginning/end of the line
  
  saveRDS(lines, file=tidyfile) 
}

tidyText(twitter, twitterRDS)
tidyText(news, newsRDS)
tidyText(blogs, blogsRDS)

df_twitter <- readRDS(twitterRDS)
df_news <- readRDS(newsRDS)
df_blogs <- readRDS(blogsRDS)

lines <- c(df_news, df_blogs, df_twitter)
rm(df_news, df_blogs, df_twitter)

# remove lines that contain less than 3 words, or ngram() would throw errors.
lines <- lines[str_count(lines, "\\s+")>1] # reduce 10483160 elements to 7730009 elements
trigram <- ngram(lines, n=3); rm(lines)
df <- get.phrasetable(trigram); rm(trigram)
saveRDS(df, en_3gramRDS)
################################################################################

## Analyze the Corpus data
################################################################################
df <- readRDS(en_3gramRDS)
head(df[grep("^case of", df[,1]),], 10)
head(df[grep("^mean the ", df[,1]),], 10)
rbind(head(df[grep("^me the bluest", df[,1]),],3),
      head(df[grep("^me the smelliest", df[,1]),],3),
      head(df[grep("^me the saddest", df[,1]),],3),
      head(df[grep("^me the happiest", df[,1]),]),3)
rbind(head(df[grep("^still struggling crowd", df[,1]),],3), 
      head(df[grep("^still struggling defense", df[,1]),],3),
      head(df[grep("^still struggling referees", df[,1]),],3),
      head(df[grep("^still struggling players", df[,1]),]),3)
head(df[grep("^date at", df[,1]),],10)
head(df[grep("^on my ", df[,1]),], 10)
head(df[grep("^quite some ", df[,1]),], 10)
rbind(head(df[grep("his little finger", df[,1]),],3), 
      head(df[grep("his little eye", df[,1]),],3),
      head(df[grep("his little ear", df[,1]),],3), 
      head(df[grep("his little toe", df[,1]),]))
rbind(head(df[grep("during the worse", df[,1]),],3), 
      head(df[grep("during the bad", df[,1]),],3),
      head(df[grep("during the hard", df[,1]),],3), 
      head(df[grep("during the sad", df[,1]),]),3)
rbind(head(df[grep("must be asleep", df[,1]),],3),
      head(df[grep("must be insensitive", df[,1]),],3),
      head(df[grep("must be callous", df[,1]),],3),
      head(df[grep("must be insane", df[,1]),]),3)
################################################################################