context("listEntries")
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
  test_that("Entries rsyncD objects can be listet", {

    serverTestingRsyncD <- newRsync(from = dirName,
                                    host = hostURL,
                                    name = nameServer,
                                    password = passwordServer)

    # rsyncD
    invisible(deleteAllEntries(db = serverTestingRsyncD))
    invisible(sendFile(db = serverTestingRsyncD, fileName = 'x.Rdata'))
    invisible(sendFile(db = serverTestingRsyncD, fileName = 'y.Rdata'))
    expectTrue(nrow(listEntries(serverTestingRsyncD)) == 2)
    invisible(deleteAllEntries(db = serverTestingRsyncD))
  })
}
test_that("Entries rsyncL objects can be listet", {

  # rsyncL
  invisible(deleteAllEntries(db = serverTestingRsyncL))
  invisible(sendFile(db = serverTestingRsyncL, fileName = 'x.Rdata'))
  invisible(sendFile(db = serverTestingRsyncL, fileName = 'y.Rdata'))
  expectTrue(nrow(listEntries(serverTestingRsyncL)) == 2)
  invisible(deleteAllEntries(db = serverTestingRsyncL))

  #   #remove traces for further tests
  #   file.remove(dir(dirName2, "Rdata|csv|json", full.names = TRUE))
  #   file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
})
