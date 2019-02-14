context("deleteEntry")
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

serverTestingRsyncL <- newRsync(from = dirName,
                                to = dirName2)

nameServer <- NULL
suppressWarnings(try(source("~/.inwt/rsync/config.R"), silent=TRUE))
if(!is.null(nameServer)){
  test_that("deleteEntry for rsyncD is working", {

    serverTestingRsyncD <- newRsync(from = dirName,
                                    host = hostURL,
                                    name = nameServer,
                                    password = passwordServer)
    #rsyncD
    invisible(deleteAllEntries(db = serverTestingRsyncD))
    expectTrue(nrow(listEntries(serverTestingRsyncD)) == 0)
    invisible(sendFile(db = serverTestingRsyncD, fileName = 'y.Rdata'))
    expectTrue(nrow(listEntries(serverTestingRsyncD)) == 1)
    invisible(deleteEntry(db = serverTestingRsyncD, entryName = 'y.Rdata'))
    expectTrue(nrow(listEntries(serverTestingRsyncD)) == 0)

  })
}


test_that("deleteEntry for rsyncL is working", {

  #rsyncL
  invisible(deleteAllEntries(db = serverTestingRsyncL))
  expectTrue(nrow(listEntries(serverTestingRsyncL)) == 0)
  invisible(sendFile(db = serverTestingRsyncL, fileName = 'y.Rdata'))
  expectTrue(nrow(listEntries(serverTestingRsyncL)) == 1)
  invisible(deleteEntry(db = serverTestingRsyncL, entryName = 'y.Rdata'))
  expectTrue(nrow(listEntries(serverTestingRsyncL)) == 0)

  # #remove traces for further tests
  # file.remove(dir(dirName2, "Rdata|csv|json", full.names = TRUE))
  # file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
})
