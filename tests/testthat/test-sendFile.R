library(testthat)
library(tidyr)

context("sendFile")
source("~/.inwt/rsync/config.R")

expectTrue <- function(a) testthat::expect_true(a)

# dirName <- tempdir()
dirName <- getwd()

dirName2 <- paste0(dirName, '/extraFolder/')
dir.create(dirName2)
# In case we run these Tests multiple times in a row:
file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
x <- 1
y <- 2
save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
save(list = "y", file = paste0(dirName, "/", "y.Rdata"))

serverTestingRsyncDHTTP <- rsync::rsyncDHTTP(host = hostURL,
                                             name = nameServer,
                                             password = passwordServer,
                                             url = urlServer)

serverTestingRsyncD <- rsync::rsyncD(host = hostURL,
                                     name = nameServer,
                                     password =passwordServer)

serverTestingRsyncL <- rsync::rsyncL(from = dirName,
                                     to = dirName2)


# rsyncD
rsync::deleteAllEntries(db = serverTestingRsyncD)
rsync::sendFile(db = serverTestingRsyncD, fileName = 'y.Rdata')
expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 1)
expectTrue(nrow(rsync::listEntries(serverTestingRsyncDHTTP)) == 1)

invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))

# rsyncDHTTP
rsync::deleteAllEntries(db = serverTestingRsyncDHTTP) # ok
rsync::sendFile(db = serverTestingRsyncDHTTP, fileName = 'y.Rdata') #ok
expectTrue(nrow(rsync::listEntries(serverTestingRsyncDHTTP)) == 1)

invisible(rsync::deleteAllEntries(db = serverTestingRsyncDHTTP))


# rsyncL
invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
invisible(rsync::sendFile(db = serverTestingRsyncL, fileName = 'y.Rdata'))
expectTrue(nrow(listEntries(serverTestingRsyncL)) == 1)
invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
