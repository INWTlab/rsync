context("sendObject")
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

serverTestingRsyncL <- newRsync(from = dirName,
                                to = dirName2)
z <- 34
nameServer <- NULL
suppressWarnings(try(source("~/.inwt/rsync/confiig.R"), silent=TRUE))
if(!is.null(nameServer)){
  test_that("sending Objects for rsyncD is working", {

    serverTestingRsyncD <- newRsync(from = dirName,
                                    host = hostURL,
                                    name = nameServer,
                                    password = passwordServer)

    # rsyncD
    deleteAllEntries(db = serverTestingRsyncD)
    sendObject(db = serverTestingRsyncD, object = z)
    expectTrue(nrow(listEntries(serverTestingRsyncD)) == 1)
    deleteAllEntries(db = serverTestingRsyncD)
    expectTrue(nrow(listEntries(serverTestingRsyncD)) == 0)

  })
}

test_that("sending Objects for rsyncL is working", {

  # rsyncL
  invisible(deleteAllEntries(db = serverTestingRsyncL))
  sendObject(db = serverTestingRsyncL, object = z)
  expectTrue(nrow(listEntries(serverTestingRsyncL)) == 1)
  invisible(deleteAllEntries(db = serverTestingRsyncL))
})
