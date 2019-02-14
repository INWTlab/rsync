context("getEntry")
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

if (!is.null(source("~/.inwt/rsync/config.R"))) {

  test_that("getEntry for rsyncD is working", {

    serverTestingRsyncD <- newRsync(from = dirName,
                                    host = hostURL,
                                    name = nameServer,
                                    password = passwordServer)

    # rsyncD
    expectTrue(nrow(deleteAllEntries(db = serverTestingRsyncD)) == 0)
    sendFile(db = serverTestingRsyncD, fileName = 'x.Rdata')
    expectTrue(nrow(listEntries(serverTestingRsyncD)) == 1)
    file.remove(paste0(dirName, '/','x.Rdata'))
    getEntry(db = serverTestingRsyncD, entryName = 'x.Rdata')
    expectTrue(file.exists(paste0(dirName, '/','x.Rdata')))
  })
}

test_that("getEntry for rsyncL is working", {

  #rsyncL:
  expectTrue(nrow(deleteAllEntries(db = serverTestingRsyncL)) == 0)
  sendFile(db = serverTestingRsyncL, fileName = 'x.Rdata')
  expectTrue(nrow(listEntries(serverTestingRsyncL)) == 1)
  file.remove(paste0(dirName, '/','x.Rdata'))
  getEntry(db = serverTestingRsyncL, entryName = 'x.Rdata')
  expectTrue(file.exists(paste0(dirName, '/','x.Rdata')))

  # #remove traces for further tests
  file.remove(dir(dirName2, "Rdata|csv|json", full.names = TRUE))
  file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
})
