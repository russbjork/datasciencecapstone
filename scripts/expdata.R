##  Load and view small pieces of data 
################################################################################
con <- file("data/en_US.twitter.txt", "r") 
## Read the first line of text
ds1 <- readLines(con, 1)
ds1
## Read the next line of text
ds2 <- readLines(con, 1) 
ds2
close(con)

## Read in the entire text file
con <- file("data/en_US.twitter.txt", "r") 
ds3 <- readLines(con) 
head(ds3)
################################################################################


## Load the entire dataset to initiate some exploration
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
# blogs
blogsfile <- "data/final/en_US/en_US.blogs.txt"
con <- file(blogsfile, open = "r")
blogsdata <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)
# news
newsfile <- "data/final/en_US/en_US.news.txt"
con <- file(newsfile, open = "r")
newsdata <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)
# twitter
twitterfile <- "data/final/en_US/en_US.twitter.txt"
con <- file(twitterfile, open = "r")
twitterdata <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)
rm(con)
################################################################################


##  Exploring the data from the three text files
################################################################################
library(stringi)
library(kableExtra)
# assign sample size
sample = 0.1
# file size
files <- round(file.info(c(blogsfile,newsfile,twitterfile))$size / 1024 ^ 2)
# characters, words, words per line, and lines summary data
chars <- sapply(list(nchar(blogsdata), nchar(newsdata), nchar(twitterdata)), sum)
words <- sapply(list(blogsdata, newsdata, twitterdata), stri_stats_latex)[4,]
wpl <- lapply(list(blogsdata, newsdata, twitterdata), function(x) stri_count_words(x))
lines <- sapply(list(blogsdata, newsdata, twitterdata), length)
wordsum = sapply(list(blogsdata, newsdata, twitterdata), function(x) summary(stri_count_words(x))[c('Min.', 'Mean', 'Max.')])
rownames(wordsum) = c('WPL.Min', 'WPL.Mean', 'WPL.Max')
summary <- data.frame(
  Files = c("en_US.blogs.txt", "en_US.news.txt", "en_US.twitter.txt"),
  FileSize = paste(files, " MB"),
  Characters = chars,
  Words = words,
  WPL = t(rbind(round(wordsum))),
  Lines =lines
)
kable(summary,
      row.names = FALSE,
      align = c("l", rep("r", 7)),
      caption = "Data Files Summary") %>% kable_styling(position = "left")
################################################################################
