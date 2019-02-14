context("identicalEntries")
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
#save(list = "y", file = paste0(dirName, "/", "y.Rdata"))

serverTestingRsyncL <- newRsync(from = dirName,
                                to = dirName2)

test_that("identicalEntries for rsyncL is working", {

  #rsyncL
  deleteAllEntries(db = serverTestingRsyncL)
  sendFile(db = serverTestingRsyncL, fileName = 'x.Rdata')
  expectTrue(nrow(listEntries(serverTestingRsyncL)) == 1)
  identicalEntries(db = serverTestingRsyncL, entryName = 'x.Rdata')
  deleteAllEntries(db = serverTestingRsyncL)
  expectTrue(nrow(listEntries(serverTestingRsyncL)) == 0)
  file.remove(paste0(dirName, '/','x.Rdata'))

  # #remove traces for further tests
  file.remove(dir(dirName2, "Rdata|csv|json", full.names = TRUE))
  file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
})
