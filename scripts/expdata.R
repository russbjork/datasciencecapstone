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





##  Explore the data within the sample
