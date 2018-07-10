library(yaml)

context("RsyncServer")


  expectTrue <- function(a) testthat::expect_true(a)

  serverTesting <- connection(
    host =   read_yaml("~/.rsync/rsync.yaml")[[1]],
    name =   read_yaml("~/.rsync/rsync.yaml")[[2]],
    password =  read_yaml("~/.rsync/rsync.yaml")[[3]],
    url =   read_yaml("~/.rsync/rsync.yaml")[[4]]
  )

  expectTrue(grepl("rsync://", serverTesting$host))
  expectTrue(is.character(serverTesting$host))
  expectTrue(grepl("https://", serverTesting$url))
  expectTrue(is.character(serverTesting$url))
  expectTrue(is.character(serverTesting$name))
  expectTrue(is.character(serverTesting$password))


  dirName <- tempdir()
  # In case we run these Tests multiple times in a row:
  file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
  save(list = "y", file = paste0(dirName, "/", "y.Rdata"))

  expectTrue(nrow(ls(deleteAllEntries(serverTesting))) == 0)
  expectTrue(nrow(ls(sendFile(serverTesting, paste0(dirName, "/", "y.Rdata")))) == 1)
  expectTrue(nrow(ls(sendFolder(serverTesting, dirName, pattern = "*.Rdata"))) == 2)
  expectTrue(get(serverTesting, "x.Rdata")$x == 1)

  # validate
  local <- function(file) paste0(dirName, "/", file)
  remote <- function(file) paste0(serverTesting$url, file)

  testthat::expect_warning(
    rsyncSuccessful(local("x.Rdata"), remote("y.Rdata")),
    regexp = "Local and remote file are not the same!"
  )
  testthat::expect_null(unlist(rsyncSuccessful(local("y.Rdata"), remote("y.Rdata"))))

  # delete
  expectTrue(nrow(ls(delete(serverTesting, "x.Rdata"))) == 1)
  expectTrue(nrow(ls(deleteAllEntries(serverTesting))) == 0)

  # send two files at once, validate results
  expectTrue(nrow(ls(sendFile(serverTesting, paste0(dirName, "/", c("x", "y"), ".Rdata")))) == 2)
  expectTrue(nrow(ls(deleteAllEntries(serverTesting))) == 0)

  z <- 3
  expectTrue(nrow(ls(sendObject(serverTesting, z))) == 1)
  expectTrue(get(serverTesting, "z.Rdata")$z == 3)
  expectTrue(nrow(ls(delete(serverTesting, "z.Rdata"))) == 0)

  # check for csv
  dat <- data.frame(
    x = 1L,
    date = "2017-01-01",
    z = 1.12345,
    stringsAsFactors = FALSE
  )
  data.table::fwrite(dat, file = paste0(dirName, "/", "dat.csv"))
  expectTrue(nrow(ls(sendFile(serverTesting, paste0(dirName, "/", "dat.csv")))) == 1)
  expectTrue(base::identical(dat, get(serverTesting, "dat.csv")))
  expectTrue(nrow(ls(deleteAllEntries(serverTesting))) == 0)

  # check for json
  lst <- list(
    x = 1:3,
    date = "2017-01-01"
  )
  jsonlite::write_json(lst, path = paste0(dirName, "/", "lst.json"))
  expectTrue(nrow(ls(sendFile(serverTesting, paste0(dirName, "/", "lst.json")))) == 1)
  expectTrue(base::identical(lst, get(serverTesting, "lst.json")))
  expectTrue(nrow(ls(deleteAllEntries(serverTesting))) == 0)



