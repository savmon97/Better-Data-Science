#-------------------------------
# Library
#-------------------------------
library(tm)
library(SnowballC)
library(wordcloud)
library(stringr)


obama <- read.csv("obama_redacted_final.csv")

names(obama)

# VectorSource pulls vector elements and turns each into
# a document
# And then we assemble that info into a corpus
# which is just a collection of text documents
reasons <- Corpus(VectorSource(obama$reasontovote))
reasons 
# now, we have 2322 documents instead of rows
inspect(reasons)

# A term document matrix is a way of arranging the data
# that can be very useful for text analysis
reasonsTDM <- TermDocumentMatrix(reasons) 
inspect(reasonsTDM)

# the terms (words) are the rows and the columns
# are the document locations (there are more than just
# what prints to console!)

# we can make this a little easier to read by changing
# up the class/layout
reasonsMT <- as.matrix(reasonsTDM) 

# reformat the matrix
reasonsMT <- sort(rowSums(reasonsMT), decreasing = TRUE) 
head(reasonsMT)

# Let's flip that around again into the format we're most
# comfortable with
reasonsDF <- data.frame(word = names(reasonsMT), freq = reasonsMT)

head(reasonsDF)


# Cleaning up the data

# for this, we'll go back to the corpus
reasons <- tm_map(reasons, removeWords, stopwords('english'))
stopwords('english')

reasons <- tm_map(reasons, removePunctuation)


reasonsTDM <- TermDocumentMatrix(reasons) 

reasonsMT <- as.matrix(reasonsTDM) 

reasonsMT <- sort(rowSums(reasonsMT), decreasing = TRUE) 

reasonsDF <- data.frame(word = names(reasonsMT), freq = reasonsMT)

head(reasonsDF)


# Making the wordcloud

pal <- brewer.pal(6,"Dark2")

wordcloud(reasonsDF$word, freq= reasonsDF$freq, max.words = 100, 
          random.order = FALSE, colors = pal)


# Let's say we wanted to remove the word "change" from the cloud
# take a moment and see if you can edit our code to ensure that
# the word "CHANGE" does not appear


reasons <- tm_map(reasons, removeWords, c("change", stopwords('english')))

reasonsTDM <- TermDocumentMatrix(reasons) 

reasonsMT <- as.matrix(reasonsTDM) 

reasonsMT <- sort(rowSums(reasonsMT), decreasing = TRUE) 

reasonsDF <- data.frame(word = names(reasonsMT), freq = reasonsMT)

head(reasonsDF)


# Making the wordcloud

pal <- brewer.pal(6,"Dark2")

wordcloud(reasonsDF$word, freq= reasonsDF$freq, max.words = 100, 
          random.order = FALSE, colors = pal)

#---------------------------------------
# Your turn!
#---------------------------------------

# Using the new ANES data on Trump and Biden,
# analyze the open-ended responses 



