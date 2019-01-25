context("loadjson")
source("~/.inwt/rsync/config.R")

test_that("json data can be loaded", {


  expectTrue <- function(a) testthat::expect_true(a)


  dirName <- tempdir()
  invisible(file.remove(paste0(dirName,'/extraFolder')))
  dirName2 <- paste0(dirName, '/extraFolder/')
  dir.create(dirName2)
  # In case we run these Tests multiple times in a row:
  file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
  lst <- list(
    x = 1:3,
    date = "2018-12-24"
  )
  jsonlite::write_json(lst, path = paste0(dirName, "/", "lst.json"))




  serverTestingRsyncD <- rsync::newRsync(from = dirName,
                                         host = hostURL,
                                         name = nameServer,
                                         password = passwordServer)

  serverTestingRsyncL <- rsync::newRsync(from = dirName,
                                         to = dirName2)




  # rsyncD
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))
  invisible(rsync::sendFile(db = serverTestingRsyncD, fileName = 'lst.json'))
  expectTrue(nrow(rsync::listEntries(serverTestingRsyncD)) == 1)
  jsonData <- rsync::loadjson(db = serverTestingRsyncD, jsonName = 'lst.json')
  expectTrue(!is.null(objects(jsonData)))
  rm(jsonData)
  expectTrue(file.exists(paste0(dirName, '/','lst.json')))
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncD))

  # rsyncL
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
  invisible(rsync::sendFile(db = serverTestingRsyncL, fileName = 'lst.json'))
  expectTrue(nrow(rsync::listEntries(serverTestingRsyncL)) == 1)
  file.remove(paste0(dirName, '/','lst.json'))

  jsonData <- rsync::loadjson(db = serverTestingRsyncL, jsonName = 'lst.json')
  expectTrue(!is.null(objects(jsonData)))
  expectTrue(file.exists(paste0(dirName, '/','lst.json')))
  file.remove(paste0(dirName, '/','lst.json'))
  invisible(rsync::deleteAllEntries(db = serverTestingRsyncL))
  rm(jsonData)
})
