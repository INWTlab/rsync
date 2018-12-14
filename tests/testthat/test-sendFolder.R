library(testthat)
library(tidyr)

context("sendFolder")
source("~/.inwt/rsync/config.R")

expectTrue <- function(a) testthat::expect_true(a)


dirName <- tempdir()


dirName2 <- paste0(dirName, '/testFolder/')
dir.create(dirName2)

exampleFolder <- paste0(dirName, '/exampleFolder/')
dir.create(exampleFolder)


# In case we run these Tests multiple times in a row:
file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
file.remove(dir(exampleFolder, "Rdata|csv|json", full.names = TRUE))
x <- 1
y <- 2
save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
save(list = "y", file = paste0(dirName, "/", "y.Rdata"))

save(list = "x", file = paste0(exampleFolder, "/", "x.Rdata"))
save(list = "y", file = paste0(exampleFolder, "/", "y.Rdata"))



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
rsync::sendFolder(local = dirName, host = serverTestingRsyncDHTTP, folderName = 'exampleFolder')

#2 rsyncD

#2 rsyncL
rsync::sendFolder(local = dirName, host = serverTestingRsyncL, folderName = 'exampleFolder')
