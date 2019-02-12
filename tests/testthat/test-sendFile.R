context("sendFile")
source("~/.inwt/rsync/config.R")

test_that("sendFile is working", {

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


  serverTestingRsyncD <- newRsync(from = dirName,
                                         host = hostURL,
                                         name = nameServer,
                                         password = passwordServer)

  serverTestingRsyncL <- newRsync(from = dirName,
                                         to = dirName2)


  # rsyncD
  deleteAllEntries(db = serverTestingRsyncD)
  sendFile(db = serverTestingRsyncD, fileName = 'y.Rdata')
  expectTrue(nrow(listEntries(serverTestingRsyncD)) == 1)
  invisible(deleteAllEntries(db = serverTestingRsyncD))

  # rsyncL
  invisible(deleteAllEntries(db = serverTestingRsyncL))
  invisible(sendFile(db = serverTestingRsyncL, fileName = 'y.Rdata'))
  expectTrue(nrow(listEntries(serverTestingRsyncL)) == 1)
  invisible(deleteAllEntries(db = serverTestingRsyncL))

  #remove traces for further tests
  file.remove(dir(dirName2, "Rdata|csv|json", full.names = TRUE))
  file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
})
