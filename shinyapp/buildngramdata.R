# buildngramdata.R
# Author: Russ Bjork
# Date: 1/10/2021
# Description: Prepare n-gram data files

library(tm)
library(dplyr)
library(stringi)
library(stringr)
library(quanteda)
library(data.table)

## Load the data files, create training data
################################################################################
trainURL <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
trainDataFile <- "data/Coursera-SwiftKey.zip"
if (!file.exists('data')) {
  dir.create('data')
}
if (!file.exists("data/final/en_US")) {
  tempFile <- tempfile()
  download.file(trainURL, tempFile)
  unzip(tempFile, exdir = "data")
  unlink(tempFile)
}
# twitter
twitterfile <- "data/final/en_US/en_US.twitter.txt"
con <- file(twitterfile, open = "r")
twitterdata <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)
rm(con)
# news
newsfile <- "data/final/en_US/en_US.news.txt"
con <- file(newsfile, open = "r")
newsdata <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)
# blogs
blogsfile <- "data/final/en_US/en_US.blogs.txt"
con <- file(blogsfile, open = "r")
blogsdata <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)

print("Loaded training data")
print(paste0("Number of lines per file (twitter): ", format(length(twitterdata), big.mark = ",")))
print(paste0("Number of lines per file (blogs):     ", format(length(blogsdata), big.mark = ",")))
print(paste0("Number of lines per file (news):    ", format(length(newsdata), big.mark = ",")))
print(paste0("Number of lines per file (total):   ", format(length(blogsdata) +
                                                              length(newsdata) +
                                                              length(twitterdata), big.mark = ",")))

# remove variables no longer needed to free up memory
rm(con, trainURL, trainDataFile, twitterfile, newsfile, blogsfile)
################################################################################

## Preparing samples of each file for analysis
################################################################################
# initiate a seed for reproducability
set.seed(216786)
# create samples and a sample file for each data file
sample = 0.01
twittersample <- sample(twitterdata, length(twitterdata) * sample, replace = FALSE)
blogsample <- sample(blogsdata, length(blogsdata) * sample, replace = FALSE)
newssample <- sample(newsdata, length(newsdata) * sample, replace = FALSE)
# remove all non-English characters
twittersample <- iconv(twittersample, "latin1", "ASCII", sub = "")
blogsample <- iconv(blogsample, "latin1", "ASCII", sub = "")
newssample <- iconv(newssample, "latin1", "ASCII", sub = "")

# remove outliers such as very long and very short articles by only including
# the IQR
normalize <- function(data) {
  first <- quantile(nchar(data), 0.25)
  third <- quantile(nchar(data), 0.75)
  data <- data[nchar(data) > first]
  data <- data[nchar(data) < third]
  return(data)
}

twittersample <- normalize(twittersample)
blogsample <- normalize(blogsample)
newssample <- normalize(newsample)

# combine all three data sets into a single data set and write to disk
sampledata <- c(twittersample, newssample, blogsample)

# get number of lines and words from the sample data set
sampledatalines <- length(sampledata)
sampledatawords <- sum(stri_count_words(sampledata))
print("Created sample data set")
print(paste0("Number of lines:  ", format(sampledatalines, big.mark = ",")))
print(paste0("Number of words: ", format(sampledatawords, big.mark = ",")))

# remove variables no longer needed to free up memory
rm(twitterdata, blogsdata, newsdata)
rm(twittersample, blogsample, newssample)
rm(normalize)
################################################################################


################################################################################
# data transformtion
library(tm)
# download bad words file
BWURL <- "https://www.freewebheaders.com/download/files/full-list-of-bad-words_text-file_2018_07_30.zip"
BWFile <- "data/full-list-of-bad-words_text-file_2018_07_30.txt"
if (!file.exists('data')) {
  dir.create('data')
}
if (!file.exists(BWFile)) {
  tempFile <- tempfile()
  download.file(BWURL, tempFile)
  unzip(tempFile, exdir = "data")
  unlink(tempFile)
}

con <- file(BWFile, open = "r")
profanity <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
profanity <- iconv(profanity, "latin1", "ASCII", sub = "")
close(con)

# convert text to lowercase
sampledata <- tolower(sampledata)

# remove URL, email addresses, Twitter handles and hash tags
sampledata <- gsub("(f|ht)tp(s?)://(.*)[.][a-z]+", "", sampledata, ignore.case = FALSE, perl = TRUE)
sampledata <- gsub("\\S+[@]\\S+", "", sampledata, ignore.case = FALSE, perl = TRUE)
sampledata <- gsub("@[^\\s]+", "", sampledata, ignore.case = FALSE, perl = TRUE)
sampledata <- gsub("#[^\\s]+", "", sampledata, ignore.case = FALSE, perl = TRUE)

# remove ordinal numbers
sampledata <- gsub("[0-9](?:st|nd|rd|th)", "", sampledata, ignore.case = FALSE, perl = TRUE)

# remove profane words
sampledata <- removeWords(sampledata, profanity)

# remove punctuation
sampledata <- gsub("[^\\p{L}'\\s]+", "", sampledata, ignore.case = FALSE, perl = TRUE)

# remove punctuation (leaving ')
sampledata <- gsub("[.\\-!]", " ", sampledata, ignore.case = FALSE, perl = TRUE)

# trim leading and trailing whitespace
sampledata <- gsub("^\\s+|\\s+$", "", sampledata)
sampledata <- stripWhitespace(sampledata)
sampledata <- sampledata[!is.na(sampledata)]
sampledata <- sampledata[sampledata != ""]

# write sample data set to disk
samplefile <- "data/en_US.sample.txt"
con <- file(samplefile, open = "w")
writeLines(sampledata, con)
close(con)

# remove variables no longer needed to free up memory
rm(BWURL, BWFile, con, samplefile, profanity)
################################################################################

################################################################################
# Build corpus
corpus <- corpus(sampleData)

# ------------------------------------------------------------------------------
# Build n-gram frequencies
# ------------------------------------------------------------------------------

getTopThree <- function(corpus) {
  first <- !duplicated(corpus$token)
  balance <- corpus[!first,]
  first <- corpus[first,]
  second <- !duplicated(balance$token)
  balance2 <- balance[!second,]
  second <- balance[second,]
  third <- !duplicated(balance2$token)
  third <- balance2[third,]
  return(rbind(first, second, third))
}

# Generate a token frequency dataframe. Do not remove stemwords because they are
# possible candidates for next word prediction.
tokenFrequency <- function(corpus, n = 1, rem_stopw = NULL) {
  corpus <- dfm(corpus, ngrams = n)
  corpus <- colSums(corpus)
  total <- sum(corpus)
  corpus <- data.frame(names(corpus),
                       corpus,
                       row.names = NULL,
                       check.rows = FALSE,
                       check.names = FALSE,
                       stringsAsFactors = FALSE
  )
  colnames(corpus) <- c("token", "n")
  corpus <- mutate(corpus, token = gsub("_", " ", token))
  corpus <- mutate(corpus, percent = corpus$n / total)
  if (n > 1) {
    corpus$outcome <- word(corpus$token, -1)
    corpus$token <- word(string = corpus$token, start = 1, end = n - 1, sep = fixed(" "))
  }
  setorder(corpus, -n)
  corpus <- getTopThree(corpus)
  return(corpus)
}

# get top 3 words to initiate the next word prediction app
startWord <- word(corpus, 1)  # get first word for each document
startWord <- tokenFrequency(startWord, n = 1, NULL)  # determine most popular start words
startWordPrediction <- startWord$token[1:3]  # select top 3 words to start word prediction app
saveRDS(startWordPrediction, "data/start-word-prediction.RData")

# bigram
bigram <- tokenFrequency(corpus, n = 2, NULL)
saveRDS(bigram, "data/bigram.RData")
remove(bigram)

# trigram
trigram <- tokenFrequency(corpus, n = 3, NULL)
trigram <- trigram %>% filter(n > 1)
saveRDS(trigram, "data/trigram.RData")
remove(trigram)

# quadgram
quadgram <- tokenFrequency(corpus, n = 4, NULL)
quadgram <- quadgram %>% filter(n > 1)
saveRDS(quadgram, "data/quadgram.RData")
remove(quadgram)
################################################################################
