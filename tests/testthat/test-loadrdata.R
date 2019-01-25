context("loadrdata")
source("~/.inwt/rsync/config.R")

test_that("rdata can be loaded", {

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
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))
  invisible(rsync::sendFile(db = serverTestingRsyncD, fileName = 'x.Rdata'))
  expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 1)
  rm(x)
  rdata <- rsync::loadrdata(db = serverTestingRsyncD, rdataName = 'x.Rdata')
  expectTrue(!is.null(objects(rdata)))
  rm(rdata)
  expectTrue(file.exists(paste0(dirName, '/','x.Rdata')))
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))

  #rsyncL
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
  invisible(rsync::sendFile(db = serverTestingRsyncL, fileName = 'x.Rdata'))
  expectTrue(nrow(rsync::listEntries(serverTestingRsyncL)) == 1)
  file.remove(paste0(dirName, '/','x.Rdata'))

  rdata <- rsync::loadrdata(db = serverTestingRsyncL, rdataName = 'x.Rdata')
  expectTrue(!is.null(objects(rdata)))
  expectTrue(file.exists(paste0(dirName, '/','x.Rdata')))
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
  rm(rdata)

  # #remove traces for further tests
  # file.remove(dir(dirName2, "Rdata|csv|json", full.names = TRUE))
  # file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))

})



