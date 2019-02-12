context("deleteAllEntries")
source("~/.inwt/rsync/config.R")

test_that("deleteAllEntries is working", {

  expectTrue <- function(a) testthat::expect_true(a)

  dirName <- tempdir()
  # invisible(file.remove(paste0(dirName,'/extraFolder')))
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

  #rsyncD
  invisible(sendFile(db = serverTestingRsyncD, fileName = 'x.Rdata'))
  invisible(sendFile(db = serverTestingRsyncD, fileName = 'y.Rdata'))
  expectTrue(!is.null(listEntries(serverTestingRsyncD)))
  invisible(deleteAllEntries(db = serverTestingRsyncD))
  expectTrue(nrow(listEntries(serverTestingRsyncD)) == 0)


  # rsyncL
  invisible(sendFile(db = serverTestingRsyncL, fileName = 'x.Rdata'))
  invisible(sendFile(db = serverTestingRsyncL, fileName = 'y.Rdata'))
  expectTrue(!is.null(listEntries(serverTestingRsyncL)))
  invisible(deleteAllEntries(db = serverTestingRsyncL))
  expectTrue(nrow(listEntries(serverTestingRsyncL)) == 0)

})

