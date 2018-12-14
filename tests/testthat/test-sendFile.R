library(testthat)
library(tidyr)

context("sendFile")
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
                                     to = dirName2) # / hinzugefügt am Ende

#"/home/dberscheid/Netzfreigaben/Git_TEX/rsyncTestFolder/"

#1 rsyncDHTTP
rsync::sendFile(local = dirName, host = serverTestingRsyncDHTTP, fileName = 'x.Rdata')

#2 rsyncD
# rsync::sendFile(local = dirName, host = serverTestingRsyncD, fileName = 'x.Rdata')

#2 rsyncL
rsync::sendFile(local = dirName, host = serverTestingRsyncL, fileName = 'y.Rdata')
