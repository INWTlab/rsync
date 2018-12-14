library(testthat)
library(tidyr)

context("loadjson")
source("~/.inwt/rsync/config.R")

expectTrue <- function(a) testthat::expect_true(a)


dirName <- tempdir()
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




#1 rsyncDHTTP
rsync::sendFile(local = dirName, host = serverTestingRsyncDHTTP, fileName = 'lst.json')
rsync::loadjson(host = serverTestingRsyncDHTTP, jsonName = 'lst.json')

#2 rsyncD
rsync::loadjson(host = serverTestingRsyncD, jsonName = 'lst.json')
