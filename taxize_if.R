library(taxize)

#DB sources initializations
taxizeDBs <- read.csv("/Users/priyanarasimhan/Dev/R-trials/tt2/taxizeDBs.csv", header=TRUE, colClasses = 'character', stringsAsFactors = FALSE)

DBNames <- c(taxizeDBs$Name)
DBIndexes <- c(as.integer(taxizeDBs$Index))

DBLookupFunctions <- c(taxizeDBs$LookupFunction)
#DBLookupArgs <- c(taxizeDBs$ExtraArgs)
DBLookpupTaxonColumn <- c(taxizeDBs$TaxonColumn)
DBEnvVars <- c(taxizeDBs$EnvVar)
choicesDB = setNames(DBIndexes, DBNames)

DBAPIKeys <- c(as.integer(taxizeDBs$ApiKeyRequired))

DBsNeedingAPIKeys <- c()
DBsNeedingAPIKeysIndexes <- c()
DBsNeedingAPIKeysEnvVar <- c()

j <- 0
for(i in DBIndexes) {
  if (DBAPIKeys[i] != 0) {
    j <- j+1
    DBsNeedingAPIKeys[j] <- DBNames[i] 
    DBsNeedingAPIKeysIndexes[j] <- j
    DBsNeedingAPIKeysEnvVar[j] <- DBEnvVars[i]
    cat(file=stderr(), " \nAdding DB ", DBNames[i], " with Env Var ", DBEnvVars[i], " j = ", j)
  }
}

choicesAPIKeys = setNames(DBsNeedingAPIKeysIndexes, DBsNeedingAPIKeys)





