library(testthat)
library(tidyr)

context("getEntry")
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
expectTrue(nrow(rsync::deleteAllEntries(db = serverTestingRsyncD)) == 0)
rsync::sendFile(db = serverTestingRsyncD, fileName = 'x.Rdata')
expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 1)
file.remove('x.Rdata')
rsync::getEntry(db = serverTestingRsyncD, entryName = 'x.Rdata')
expectTrue(file.exists('x.Rdata'))

# rsyncDHTTP
file.remove('x.Rdata')
rsync::getEntry(db = serverTestingRsyncDHTTP, entryName = 'x.Rdata') #auch bei HTTP kann über deamon heruntergeladen werden
expectTrue(file.exists('x.Rdata'))

#rsyncL: nicht benötigt

