library(testthat)
library(tidyr)

context("loadrdata")
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
invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))
invisible(rsync::sendFile(db = serverTestingRsyncD, fileName = 'x.Rdata'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 1)
rm(x)
rdata <- rsync::loadrdata(db = serverTestingRsyncD, rdataName = 'x.Rdata')
expectTrue(!is.null(objects(rdata)))
rm(rdata)
expectTrue(file.exists('x.Rdata'))
invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))

# rsyncDHTTP
invisible(rsync::deleteAllEntries(db = serverTestingRsyncDHTTP))
invisible(rsync::sendFile(db = serverTestingRsyncDHTTP, fileName = 'x.Rdata'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncDHTTP)) == 1)
file.remove('x.Rdata')
rdata <- rsync::loadrdata(db = serverTestingRsyncDHTTP, rdataName = 'x.Rdata')
expectTrue(!is.null(objects(rdata)))
expectTrue(file.exists('x.Rdata'))
invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))
rm(rdata)

#rsyncL
invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
invisible(rsync::sendFile(db = serverTestingRsyncL, fileName = 'x.Rdata'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncL)) == 1)
file.remove('x.Rdata')

rdata <- rsync::loadrdata(db = serverTestingRsyncL, rdataName = 'x.Rdata')
expectTrue(!is.null(objects(rdata)))
expectTrue(file.exists('x.Rdata'))
invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
rm(rdata)


