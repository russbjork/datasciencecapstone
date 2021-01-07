##  Load and view small pieces of the raw data files
################################################################################
## Peek into the twitter data
con <- file("data/final/en_US/en_US.twitter.txt", "r") 
ds1 <- readLines(con, 5)
close(con)
ds1
## Peek into the news data
con <- file("data/final/en_US/en_US.news.txt", "r") 
ds2 <- readLines(con, 5)
close(con)
ds2
## Peek into the blogs data
con <- file("data/final/en_US/en_US.blogs.txt", "r") 
ds3 <- readLines(con, 5)
close(con)
ds3
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
################################################################################


##  Summarize the data from the three text files
################################################################################
library(stringi)
library(kableExtra)
# file size
files <- round(file.info(c(twitterfile,newsfile,blogsfile))$size / 1024 ^ 2)
# characters, words, words per line, and lines summary data
chars <- sapply(list(nchar(twitterdata), nchar(newsdata), nchar(blogsdata)), sum)
words <- sapply(list(twitterdata, newsdata, blogsdata), stri_stats_latex)[4,]
wpl <- lapply(list(twitterdata, newsdata, blogsdata), function(x) stri_count_words(x))
lines <- sapply(list(twitterdata, newsdata, blogsdata), length)
wordsum = sapply(list(twitterdata, newsdata, blogsdata), 
  function(x) summary(stri_count_words(x))[c('Min.', 'Mean', 'Max.')])
rownames(wordsum) = c('WPL.Min', 'WPL.Mean', 'WPL.Max')
summary <- data.frame(
  Files = c("en_US.twitter.txt", "en_US.news.txt", "en_US.blogs.txt"),
  FileSize = paste(files, " MB"),
  Characters = chars,
  Words = words,
  WPL = t(rbind(round(wordsum))),
  Lines =lines
)
kable(summary,
      col.names = c("Files","File Size","Characters","Words","WPL Min","WPL Mean","WPL Max","Lines"),
      row.names = FALSE,
      align = c("l", rep("r", 7)),
      caption = "Data Files Summary") %>% 
      kable_styling(bootstrap_options = c("striped", "hover", font_size = 10))
################################################################################


## Plotting out the summary on each file
################################################################################
library(ggplot2)
plot1 <- qplot(wpl[[1]],
               geom = "histogram",
               main = "Twitter",
               xlab = "Words per Line",
               ylab = "Count",
               binwidth = 1) + coord_cartesian(xlim = c(0, 100)) +
               scale_y_continuous(labels = scales::comma)
plot2 <- qplot(wpl[[2]],
               geom = "histogram",
               main = "News",
               xlab = "Words per Line",
               ylab = "Count",
               binwidth = 1) + coord_cartesian(xlim = c(0, 200)) +
               scale_y_continuous(labels = scales::comma)
plot3 <- qplot(wpl[[3]],
               geom = "histogram",
               main = "Blogs",
               xlab = "Words per Line",
               ylab = "Count",
               binwidth = 1) + coord_cartesian(xlim = c(0, 300)) +
              scale_y_continuous(labels = scales::comma)
plot1
plot2
plot3
################################################################################


## Preparing samples of each file for analysis
################################################################################
# initiate a seed for reproducability
set.seed(216786)
# create samples and a sample file for each data file
sample = 0.1
twittersample <- sample(twitterdata, length(twitterdata) * sample, replace = FALSE)
blogsample <- sample(blogsdata, length(blogsdata) * sample, replace = FALSE)
newssample <- sample(newsdata, length(newsdata) * sample, replace = FALSE)
# remove all non-English characters
twittersample <- iconv(twittersample, "latin1", "ASCII", sub = "")
blogsample <- iconv(blogsample, "latin1", "ASCII", sub = "")
newssample <- iconv(newssample, "latin1", "ASCII", sub = "")
# combine all three data sets into a single data set and write to disk
sampledata <- c(twittersample, newssample, blogsample)
samplefile <- "data/final/en_US/en_US.sample.txt"
con <- file(samplefile, open = "w")
writeLines(sampledata, con)
close(con)
# get number of lines and words from the sample data set
samplelines <- length(sampledata);
samplewords <- sum(stri_count_words(sampledata))
# remove variables no longer needed to free up memory
rm(twitterdata, blogsdata, newsdata)
rm(twittersample, blogsample, newssample)
################################################################################