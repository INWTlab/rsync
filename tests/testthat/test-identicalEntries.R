library(testthat)
library(tidyr)

context("identicalEntries")
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
#save(list = "y", file = paste0(dirName, "/", "y.Rdata"))



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
rsync::deleteAllEntries(host = serverTestingRsyncDHTTP)
rsync::sendFile(local = dirName, host = serverTestingRsyncDHTTP, fileName = 'x.Rdata')
rsync::identicalEntries(local = dirName, host = serverTestingRsyncDHTTP, entryName = 'x.Rdata')
# rsync::rsyncSuccessful()

#2:
rsync::identicalEntries(local = dirName, host = serverTestingRsyncD, entryName = 'x.Rdata')

#3:
rsync::sendFile(local = dirName, host = serverTestingRsyncL, fileName = 'x.Rdata')
rsync::identicalEntries(local = dirName, host = serverTestingRsyncL, entryName = 'x.Rdata')
