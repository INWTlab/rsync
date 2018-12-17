library(testthat)
library(tidyr)

context("rsyncFile")
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




#1) send and get with rsyncDHTTP
  #get
invisible(rsync::deleteAllEntries(host = serverTestingRsyncDHTTP))
invisible(rsync::sendFile(local = dirName, host = serverTestingRsyncDHTTP, fileName = 'x.Rdata'))
file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
rsync::rsyncFile(local = dirName, host = serverTestingRsyncDHTTP, fileName = 'x.Rdata', direction = 'get', args = "-ltx")
expectTrue(nrow(listDir(dirName)) == 1)

  #send
invisible(rsync::deleteAllEntries(host = serverTestingRsyncDHTTP))
rsync::rsyncFile(local = dirName, host = serverTestingRsyncDHTTP, fileName = 'x.Rdata', direction = 'send', args = "-ltx")
expectTrue(nrow(rsync::listEntries(serverTestingRsyncDHTTP)) == 1)



#2:get with rsyncD
invisible(rsync::deleteAllEntries(host = serverTestingRsyncD))
invisible(rsync::sendFile(local = dirName, host = serverTestingRsyncD, fileName = 'x.Rdata'))
file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
rsync::rsyncFile(local = dirName, host = serverTestingRsyncD, fileName = 'x.Rdata', direction = 'get', args = "-ltx")
expectTrue(nrow(listDir(dirName)) == 1)

# send with rsyncD not needed


#3: send with rsyncL
invisible(rsync::deleteAllEntries(host = serverTestingRsyncL))
rsync::rsyncFile(local = dirName, host = serverTestingRsyncL, fileName = 'x.Rdata', direction = 'send', args = "-ltx")
expectTrue(nrow(listEntries(host = serverTestingRsyncL)) == 0)
# get with rsyncL not needed

