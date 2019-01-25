context("loadcsv")
source("~/.inwt/rsync/config.R")

test_that("csv can be loaded", {

  expectTrue <- function(a) testthat::expect_true(a)

  dirName <- tempdir()
  invisible(file.remove(paste0(dirName,'/extraFolder')))
  dirName2 <- paste0(dirName, '/extraFolder/')
  dir.create(dirName2)
  # In case we run these Tests multiple times in a row:
  file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))

  dat <- data.frame(
    x = 1L,
    date = "2018-12-24",
    z = 1.12345,
    stringsAsFactors = FALSE
  )

  data.table::fwrite(dat, file = paste0(dirName, "/", "x.csv"))


  serverTestingRsyncD <- rsync::newRsync(from = dirName,
                                         host = hostURL,
                                         name = nameServer,
                                         password = passwordServer)

  serverTestingRsyncL <- rsync::newRsync(from = dirName,
                                         to = dirName2)



  # rsyncD
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))
  invisible(rsync::sendFile(db = serverTestingRsyncD, fileName = 'x.csv'))
  expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 1)
  csvData <- rsync::loadcsv(db = serverTestingRsyncD, csvName = 'x.csv')
  expectTrue(!is.null(objects(csvData)))
  expectTrue(file.exists(paste0(dirName, '/','x.csv')))
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))


  #rsyncL
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
  invisible(rsync::sendFile(db = serverTestingRsyncL, fileName = 'x.csv'))
  expectTrue(nrow(rsync::listEntries(serverTestingRsyncL)) == 1)
  file.remove(paste0(dirName, '/','x.csv'))
  rm(csvData)
  csvData <- rsync::loadcsv(db = serverTestingRsyncL, csvName = 'x.csv')
  expectTrue(!is.null(objects(csvData)))
  expectTrue(file.exists(paste0(dirName, '/','x.csv')))
  file.remove(paste0(dirName, '/','x.csv'))
  rm(csvData)
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))

})
