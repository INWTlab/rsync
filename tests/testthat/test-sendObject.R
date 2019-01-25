context("sendObject")
source("~/.inwt/rsync/config.R")

test_that("sending Objects is working", {

  expectTrue <- function(a) testthat::expect_true(a)

  dirName <- tempdir()
  # try(file.remove(paste0(dirName,'/extraFolder')), silent = TRUE)
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

  z <- 34

  # rsyncD
  rsync::deleteAllEntries(db = serverTestingRsyncD)
  rsync::sendObject(db = serverTestingRsyncD, object = z)
  expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 1)
  rsync::deleteAllEntries(db = serverTestingRsyncD)
  expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 0)


  # rsyncL
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
  rsync::sendObject(db = serverTestingRsyncL, object = z)
  expectTrue(nrow(listEntries(serverTestingRsyncL)) == 1)
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))


})
