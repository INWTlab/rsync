library(testthat)
library(tidyr)

context("listEntries")
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


#1:
invisible(rsync::deleteAllEntries(host = serverTestingRsyncDHTTP))
invisible(rsync::sendFile(local = dirName, host = serverTestingRsyncDHTTP, fileName = 'x.Rdata'))
invisible(rsync::sendFile(local = dirName, host = serverTestingRsyncDHTTP, fileName = 'y.Rdata'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncDHTTP)) == 2)
invisible(rsync::deleteAllEntries(host = serverTestingRsyncDHTTP))


#2:

invisible(rsync::deleteAllEntries(host = serverTestingRsyncD))
invisible(rsync::sendFile(local = dirName, host = serverTestingRsyncD, fileName = 'x.Rdata'))
invisible(rsync::sendFile(local = dirName, host = serverTestingRsyncD, fileName = 'y.Rdata'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 2)
invisible(rsync::deleteAllEntries(host = serverTestingRsyncD))


#3:
invisible(rsync::deleteAllEntries(host = serverTestingRsyncL))
invisible(rsync::sendFile(local = dirName, host = serverTestingRsyncL, fileName = 'x.Rdata'))
invisible(rsync::sendFile(local = dirName, host = serverTestingRsyncL, fileName = 'y.Rdata'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncL)) == 2)
invisible(rsync::deleteAllEntries(host = serverTestingRsyncL))
