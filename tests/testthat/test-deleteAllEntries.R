library(testthat)
library(tidyr)

context("deleteAllEntries")
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


#rsyncD
invisible(rsync::sendFile(db = serverTestingRsyncD, fileName = 'x.Rdata'))
invisible(rsync::sendFile(db = serverTestingRsyncD, fileName = 'y.Rdata'))
expectTrue(!is.null(rsync::listEntries(serverTestingRsyncD)))
invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 0)


# rsyncDHTTP
invisible(rsync::sendFile(db = serverTestingRsyncDHTTP, fileName = 'x.Rdata'))
invisible(rsync::sendFile(db = serverTestingRsyncDHTTP, fileName = 'y.Rdata'))
expectTrue(!is.null(rsync::listEntries(serverTestingRsyncDHTTP)))
invisible(rsync::deleteAllEntries(db = serverTestingRsyncDHTTP))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncDHTTP)) == 0)

#3: rsyncL
invisible(rsync::sendFile(db = serverTestingRsyncL, fileName = 'x.Rdata'))
invisible(rsync::sendFile(db = serverTestingRsyncL, fileName = 'y.Rdata'))
expectTrue(!is.null(rsync::listEntries(serverTestingRsyncL)))
invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncL)) == 0)
