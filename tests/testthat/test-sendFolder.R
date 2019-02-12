context("sendFolder")
source("~/.inwt/rsync/config.R")

test_that("sending a Folder is working", {

  expectTrue <- function(a) testthat::expect_true(a)

  dirName <- tempdir()

  dirName2 <- paste0(dirName, '/testFolder/')
  dir.create(dirName2)
  try(file.remove(paste0(dirName,'/extraFolder')), silent = TRUE)
  exampleFolder <- paste0(dirName, '/exampleFolder/')
  dir.create(exampleFolder)#TODO


  # In case we run these Tests multiple times in a row:
  file.remove(dir(dirName2, "Rdata|csv|json", full.names = TRUE))
  file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
  file.remove(dir(exampleFolder, "Rdata|csv|json", full.names = TRUE))
  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
  save(list = "y", file = paste0(dirName, "/", "y.Rdata"))

  save(list = "x", file = paste0(exampleFolder, "/", "x.Rdata"))
  save(list = "y", file = paste0(exampleFolder, "/", "y.Rdata"))



  serverTestingRsyncD <- newRsync(from = dirName,
                                         host = hostURL,
                                         name = nameServer,
                                         password = passwordServer)

  serverTestingRsyncL <- newRsync(from = dirName,
                                         to = dirName2)


  # rsyncD
  invisible(deleteAllEntries(db = serverTestingRsyncD))
  sendFolder(db = serverTestingRsyncD, folderName = 'exampleFolder')
  expectTrue(nrow(listEntries(serverTestingRsyncD)) == 2)
  invisible(deleteAllEntries(db = serverTestingRsyncD))

  # rsyncL
  sendFolder(db = serverTestingRsyncL, folderName = 'exampleFolder')
  expectTrue(nrow(listDir(serverTestingRsyncL$to)) == 2)

  # #remove traces for further tests
  # file.remove(dir(dirName2, "Rdata|csv|json", full.names = TRUE))
  # file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
})
