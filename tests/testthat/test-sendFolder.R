library(testthat)
library(tidyr)

context("sendFolder")
source("~/.inwt/rsync/config.R")

expectTrue <- function(a) testthat::expect_true(a)


# dirName <- tempdir()
dirName <- getwd()


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




#2 rsyncD
invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))
rsync::sendFolder(db = serverTestingRsyncD, folderName = 'exampleFolder')
expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 2)
invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))



#1 rsyncDHTTP
rsync::sendFolder(db = serverTestingRsyncDHTTP, folderName = 'exampleFolder')
expectTrue(nrow(rsync::listEntries(serverTestingRsyncDHTTP)) == 2)
invisible(rsync::deleteAllEntries(db = serverTestingRsyncDHTTP))


#2 rsyncL
rsync::sendFolder(db = serverTestingRsyncL, folderName = 'exampleFolder')
expectTrue(nrow(listDir(serverTestingRsyncL$to)) == 2)


