library(testthat)
library(tidyr)

context("loadjson")
source("~/.inwt/rsync/config.R")

expectTrue <- function(a) testthat::expect_true(a)


# dirName <- tempdir()
dirName <- getwd()
dirName2 <- paste0(dirName, '/extraFolder/')
dir.create(dirName2)
# In case we run these Tests multiple times in a row:
file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
lst <- list(
  x = 1:3,
  date = "2018-12-24"
)
jsonlite::write_json(lst, path = paste0(dirName, "/", "lst.json"))




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
invisible(rsync::sendFile(db = serverTestingRsyncD, fileName = 'lst.json'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 1)
rsync::loadjson(db = serverTestingRsyncD, jsonName = 'lst.json')
expectTrue(file.exists('lst.json'))
invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))


# rsyncDHTTP
invisible(rsync::deleteAllEntries(db = serverTestingRsyncDHTTP))
invisible(rsync::sendFile(db = serverTestingRsyncDHTTP, fileName = 'lst.json'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncDHTTP)) == 1)
file.remove('lst.json')
rsync::loadjson(db = serverTestingRsyncDHTTP, jsonName = 'lst.json')
expectTrue(file.exists('lst.json'))

invisible(rsync::deleteAllEntries(db = serverTestingRsyncDHTTP))


# rsyncL
invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
invisible(rsync::sendFile(db = serverTestingRsyncL, fileName = 'lst.json'))
expectTrue(nrow(rsync::listEntries(serverTestingRsyncL)) == 1)
file.remove('lst.json')
rsync::loadjson(db = serverTestingRsyncL, jsonName = 'lst.json')
expectTrue(file.exists('lst.json'))
file.remove('lst.json')
invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
