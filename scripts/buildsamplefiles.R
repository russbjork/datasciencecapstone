## Pull random sample of lines from file
################################################################################
# Create a sample working file for Blog data
library(LaF)
con <- file("data/final/en_US/en_US.blogs.txt", "r") 
dsfull <-  readLines(con)
tmpcsv  <- tempfile(fileext="csv")
blogsample <- file("data/final/en_US/en_blogsample.txt", "w")
writeLines(dsfull, con=tmpcsv)
writeLines(sample_lines(tmpcsv, 100),blogsample)

## Close the connection
close(con)
close(blogsample) 

# Cleanup
file.remove(tmpcsv)
################################################################################

################################################################################
# Create a sample working file for News data
library(LaF)
con <- file("data/final/en_US/en_US.news.txt", "r") 
dsfull <-  readLines(con)
tmpcsv  <- tempfile(fileext="csv")
newssample <- file("data/final/en_US/en_newssample.txt", "w")
writeLines(dsfull, con=tmpcsv)
writeLines(sample_lines(tmpcsv, 100),newssample)

## Close the connection
close(con)
close(newssample) 

# Cleanup
file.remove(tmpcsv)
################################################################################

################################################################################
# Create a sample working file for Twitter data
library(LaF)
dsfull <-  readLines(con)
con <- file("data/final/en_US/en_US.twitter.txt", "r") 
tmpcsv  <- tempfile(fileext="csv")
twittersample <- file("data/final/en_US/en_twitsample.txt", "w")
writeLines(dsfull, con=tmpcsv)
writeLines(sample_lines(tmpcsv, 100),twittersample)

## Close the connection
close(con)
close(twittersample) 

# Cleanup
file.remove(tmpcsv)
################################################################################
