library(testthat)
library(tidyr)

context("getFile")
source("~/.inwt/rsync/config.R")

expectTrue <- function(a) testthat::expect_true(a)


dirName <- tempdir()
# In case we run these Tests multiple times in a row:
file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
x <- 1
y <- 2
# save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
save(list = "y", file = paste0(dirName, "/", "y.Rdata"))



serverTestingRsyncDHTTP <- rsync::rsyncDHTTP(host = hostURL,
                                             name = nameServer,
                                             password = passwordServer,
                                             url = urlServer)



serverTestingRsyncD <- rsync::rsyncD(host = hostURL,
                                     name = nameServer,
                                     password =passwordServer)



serverTestingRsyncL <- rsync::rsyncL(from = dirName,
                                     to = "/home/dberscheid/Netzfreigaben/Git_TEX/rsync")



#1 rsyncDHTTP
rsync::getFile(local = "/home/dberscheid/Netzfreigaben/Git_TEX/rsync", host = serverTestingRsyncDHTTP, fileName = 'x.Rdata')

#2 rsyncD
rsync::getFile(local = "/home/dberscheid/Netzfreigaben/Git_TEX/rsync", host = serverTestingRsyncD, fileName = 'x.Rdata')


