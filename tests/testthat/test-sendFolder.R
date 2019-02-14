context("sendFolder")
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

serverTestingRsyncL <- newRsync(from = dirName,
                                to = dirName2)


if (!is.null(source("~/.inwt/rsync/config.R"))) {
test_that("sending a Folder with rsynD is working", {

  serverTestingRsyncD <- newRsync(from = dirName,
                                         host = hostURL,
                                         name = nameServer,
                                         password = passwordServer)

  # rsyncD
  invisible(deleteAllEntries(db = serverTestingRsyncD))
  sendFolder(db = serverTestingRsyncD, folderName = 'exampleFolder')
  expectTrue(nrow(listEntries(serverTestingRsyncD)) == 2)
  invisible(deleteAllEntries(db = serverTestingRsyncD))
})
}

test_that("sending a Folder with rsynL is working", {

# rsyncL
sendFolder(db = serverTestingRsyncL, folderName = 'exampleFolder')
expectTrue(nrow(listDir(serverTestingRsyncL$to)) == 2)

# #remove traces for further tests
# file.remove(dir(dirName2, "Rdata|csv|json", full.names = TRUE))
# file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))

})
