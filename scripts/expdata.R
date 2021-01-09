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
sample = 0.01
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
transform <- function (dataSet) {
  docs <- VCorpus(VectorSource(dataSet))
  toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
  # remove URL, Twitter handles and email patterns
  docs <- tm_map(docs, toSpace, "(f|ht)tp(s?)://(.*)[.][a-z]+")
  docs <- tm_map(docs, toSpace, "@[^\\s]+")
  docs <- tm_map(docs, toSpace, "\\b[A-Z a-z 0-9._ - ]*[@](.*?)[.]{1,3} \\b")
  # remove profane words from the sample data set
  con <- file(BWFile, open = "r")
  profanity <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
  close(con)
  profanity <- iconv(profanity, "latin1", "ASCII", sub = "")
  docs <- tm_map(docs, removeWords, profanity)
  docs <- tm_map(docs, tolower)
  docs <- tm_map(docs, removeWords, stopwords("english"))
  docs <- tm_map(docs, removePunctuation)
  docs <- tm_map(docs, removeNumbers)
  docs <- tm_map(docs, stripWhitespace)
  docs <- tm_map(docs, PlainTextDocument)
  return(docs)
}
# build the corpus and write to disk
corpus <- transform(sampledata)
saveRDS(corpus, file = "data/final/en_US/en_US.corpus.rds")
# convert corpus to a dataframe and write lines/words to disk (text)
corpusfile <- data.frame(text = unlist(sapply(corpus, '[', "content")), stringsAsFactors = FALSE)
con <- file("data/final/en_US/en_US.corpus.txt", open = "w")
writeLines(corpusfile$text, con)
close(con)
kable(head(corpusfile$text, 10),
      row.names = FALSE,
      col.names = NULL,
      align = c("l"),
      caption = "First 10 Documents") %>% kable_styling(position = "left")
rm(sampledata)
################################################################################

################################################################################
# Most frequest words found in the corpus
library(tm)
library(ggplot2)
library(wordcloud)
library(RColorBrewer)
tdm <- TermDocumentMatrix(corpus)
freq <- sort(rowSums(as.matrix(tdm)), decreasing = TRUE)
wordFreq <- data.frame(word = names(freq), freq = freq)
# plot the top 10 most frequent words
g <- ggplot (wordFreq[1:10,], aes(x = reorder(wordFreq[1:10,]$word, -wordFreq[1:10,]$fre),
                                  y = wordFreq[1:10,]$fre ))
g <- g + geom_bar( stat = "Identity" , fill = I("grey50"))
g <- g + geom_text(aes(label = wordFreq[1:10,]$fre), vjust = -0.20, size = 3)
g <- g + xlab("")
g <- g + ylab("Word Frequencies")
g <- g + theme(plot.title = element_text(size = 14, hjust = 0.5, vjust = 0.5),
               axis.text.x = element_text(hjust = 0.5, vjust = 0.5, angle = 45),
               axis.text.y = element_text(hjust = 0.5, vjust = 0.5))
g <- g + ggtitle("10 Most Frequent Words")
print(g)
# construct word cloud
suppressWarnings (
  wordcloud(words = wordFreq$word,
            freq = wordFreq$freq,
            min.freq = 1,
            max.words = 100,
            random.order = FALSE,
            rot.per = 0.35, 
            colors=brewer.pal(8, "Dark2"))
)
# remove variables no longer needed to free up memory
rm(tdm, freq, wordFreq, g)
################################################################################

################################################################################
# Tokenize and build the N-Grams
library(RWeka)
unigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 1, max = 1))
bigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
trigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))


# Create the Unigram
unigramMatrix <- TermDocumentMatrix(corpus, control = list(tokenize = unigramTokenizer))
# eliminate sparse terms for each n-gram and get frequencies of most common n-grams
unigramMatrixFreq <- sort(rowSums(as.matrix(removeSparseTerms(unigramMatrix, 0.99))), decreasing = TRUE)
unigramMatrixFreq <- data.frame(word = names(unigramMatrixFreq), freq = unigramMatrixFreq)
# generate the Unigram plot
g <- ggplot(unigramMatrixFreq[1:20,], aes(x = reorder(word, -freq), y = freq))
g <- g + geom_bar(stat = "identity", fill = I("grey50"))
g <- g + geom_text(aes(label = freq ), vjust = -0.20, size = 3)
g <- g + xlab("")
g <- g + ylab("Frequency")
g <- g + theme(plot.title = element_text(size = 14, hjust = 0.5, vjust = 0.5),
               axis.text.x = element_text(hjust = 1.0, angle = 45),
               axis.text.y = element_text(hjust = 0.5, vjust = 0.5))
g <- g + ggtitle("20 Most Common Unigrams")
print(g)

# Create the Bigram
bigramMatrix <- TermDocumentMatrix(corpus, control = list(tokenize = bigramTokenizer))
# eliminate sparse terms for each n-gram and get frequencies of most common n-grams
bigramMatrixFreq <- sort(rowSums(as.matrix(removeSparseTerms(bigramMatrix, 0.999))), decreasing = TRUE)
bigramMatrixFreq <- data.frame(word = names(bigramMatrixFreq), freq = bigramMatrixFreq)
# generate the Bigram plot
g <- ggplot(bigramMatrixFreq[1:20,], aes(x = reorder(word, -freq), y = freq))
g <- g + geom_bar(stat = "identity", fill = I("grey50"))
g <- g + geom_text(aes(label = freq ), vjust = -0.20, size = 3)
g <- g + xlab("")
g <- g + ylab("Frequency")
g <- g + theme(plot.title = element_text(size = 14, hjust = 0.5, vjust = 0.5),
               axis.text.x = element_text(hjust = 1.0, angle = 45),
               axis.text.y = element_text(hjust = 0.5, vjust = 0.5))
g <- g + ggtitle("20 Most Common Bigrams")
print(g)

# Create the Trigram
trigramMatrix <- TermDocumentMatrix(corpus, control = list(tokenize = trigramTokenizer))
# eliminate sparse terms for each n-gram and get frequencies of most common n-grams
trigramMatrixFreq <- sort(rowSums(as.matrix(removeSparseTerms(trigramMatrix, 0.9999))), decreasing = TRUE)
trigramMatrixFreq <- data.frame(word = names(trigramMatrixFreq), freq = trigramMatrixFreq)
# generate the Trigram plot
g <- ggplot(trigramMatrixFreq[1:20,], aes(x = reorder(word, -freq), y = freq))
g <- g + geom_bar(stat = "identity", fill = I("grey50"))
g <- g + geom_text(aes(label = freq ), vjust = -0.20, size = 3)
g <- g + xlab("")
g <- g + ylab("Frequency")
g <- g + theme(plot.title = element_text(size = 14, hjust = 0.5, vjust = 0.5),
               axis.text.x = element_text(hjust = 1.0, angle = 45),
               axis.text.y = element_text(hjust = 0.5, vjust = 0.5))
g <- g + ggtitle("20 Most Common Trigrams")
print(g)
################################################################################