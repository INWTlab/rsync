library(testthat)
library(tidyr)

context("deleteEntry")
source("~/.inwt/rsync/config.R")

expectTrue <- function(a) testthat::expect_true(a)


dirName <- tempdir()
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



#1: rsyncDHTTP
invisible(rsync::deleteAllEntries(host = serverTestingRsyncDHTTP))
expectTrue(nrow(listEntries(serverTestingRsyncDHTTP)) == 0)
invisible(rsync::sendFile(local = dirName, host = serverTestingRsyncDHTTP, fileName = 'x.Rdata'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncDHTTP)) == 1)
invisible(rsync::deleteEntry(host = serverTestingRsyncDHTTP, entryName = 'x.Rdata'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncDHTTP)) == 0)


#2: rsyncD
invisible(rsync::deleteAllEntries(host = serverTestingRsyncD))
expectTrue(nrow(listEntries(serverTestingRsyncD)) == 0)
invisible(rsync::sendFile(local = dirName, host = serverTestingRsyncD, fileName = 'y.Rdata'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 1)
invisible(rsync::deleteEntry(host = serverTestingRsyncD, entryName = 'y.Rdata'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 0)



#3: rsyncL
invisible(rsync::deleteAllEntries(host = serverTestingRsyncL))
expectTrue(nrow(listEntries(serverTestingRsyncL)) == 0)
invisible(rsync::sendFile(local = dirName, host = serverTestingRsyncL, fileName = 'y.Rdata'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncL)) == 1)
invisible(rsync::deleteEntry(host = serverTestingRsyncL, entryName = 'y.Rdata'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncL)) == 0)
