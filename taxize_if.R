library(taxize)

#DB sources initializations
taxizeDBs <- read.csv("/Users/priyanarasimhan/Dev/R-trials/tt2/taxizeDBs.csv", header=TRUE, colClasses = 'character', stringsAsFactors = FALSE)

DBNames <- c(taxizeDBs$Name)
DBIndexes <- c(as.integer(taxizeDBs$Index))

DBLookupFunctions <- c(taxizeDBs$LookupFunction)
