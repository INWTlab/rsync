library(testthat)
library(tidyr)

context("loadcsv")
source("~/.inwt/rsync/config.R")

expectTrue <- function(a) testthat::expect_true(a)


dirName <- tempdir()
dirName2 <- paste0(dirName, '/extraFolder/')
dir.create(dirName2
# In case we run these Tests multiple times in a row:
file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))

dat <- data.frame(
  x = 1L,
  date = "2018-12-24",
  z = 1.12345,
  stringsAsFactors = FALSE
)

data.table::fwrite(dat, file = paste0(dirName, "/", "x.csv"))



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
rsync::sendFile(local = dirName, host = serverTestingRsyncDHTTP, fileName = 'x.csv')
rsync::loadcsv(host = serverTestingRsyncDHTTP, csvName = 'x.csv')

#2 rsyncD
rsync::loadcsv(host = serverTestingRsyncD, csvName = 'x.csv')
