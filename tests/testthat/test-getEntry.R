context("getEntry")
source("~/.inwt/rsync/config.R")

test_that("getEntry is working", {

  expectTrue <- function(a) testthat::expect_true(a)


  dirName <- tempdir()
  try(file.remove(paste0(dirName,'/extraFolder')), silent = TRUE)
  dirName2 <- paste0(dirName, '/extraFolder/')
  dir.create(dirName2)
  # In case we run these Tests multiple times in a row:
  file.remove(dir(dirName2, "Rdata|csv|json", full.names = TRUE))
  file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
  save(list = "y", file = paste0(dirName, "/", "y.Rdata"))

  serverTestingRsyncD <- rsync::newRsync(from = dirName,
                                         host = hostURL,
                                         name = nameServer,
                                         password = passwordServer)

  serverTestingRsyncL <- rsync::newRsync(from = dirName,
                                         to = dirName2)



  # rsyncD
  expectTrue(nrow(rsync::deleteAllEntries(db = serverTestingRsyncD)) == 0)
  rsync::sendFile(db = serverTestingRsyncD, fileName = 'x.Rdata')
  expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 1)
  file.remove(paste0(dirName, '/','x.Rdata'))
  rsync::getEntry(db = serverTestingRsyncD, entryName = 'x.Rdata')
  expectTrue(file.exists(paste0(dirName, '/','x.Rdata')))



  #rsyncL: nicht benötigt

  # #remove traces for further tests
  # file.remove(dir(dirName2, "Rdata|csv|json", full.names = TRUE))
  # file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))

})
