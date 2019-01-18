library(testthat)
library(tidyr)

context("sendObject")
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

z <- 34

# rsyncD
rsync::deleteAllEntries(db = serverTestingRsyncD)
rsync::sendObject(db = serverTestingRsyncD, object = z)
expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 1)
rsync::deleteAllEntries(db = serverTestingRsyncD)
expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 0)


#1 rsyncDHTTP
rsync::sendObject(db = serverTestingRsyncDHTTP, object = z)
expectTrue(nrow(rsync::listEntries(serverTestingRsyncDHTTP)) == 1)
rsync::deleteAllEntries(db = serverTestingRsyncDHTTP)
expectTrue(nrow(rsync::listEntries(serverTestingRsyncDHTTP)) == 0)



#2 rsyncL
invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
rsync::sendObject(db = serverTestingRsyncL, object = z)
expectTrue(nrow(listEntries(serverTestingRsyncL)) == 1)
invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
