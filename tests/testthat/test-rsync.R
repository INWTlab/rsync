library(yaml)
library(testthat)

context("RsyncServer")


serverTestingL2R <- rsync::connection( type = "L2R",
                       host =   read_yaml("~/.inwt/rsync/config.yaml")[[1]],
                       name =   read_yaml("~/.inwt/rsync/config.yaml")[[2]],
                       password =  read_yaml("~/.inwt/rsync/config.yaml")[[3]],
                       url =   read_yaml("~/.inwt/rsync/config.yaml")[[4]])



serverTestingR2L <- rsync::connection( type = "R2L",
                             host =   read_yaml("~/.inwt/rsync/config.yaml")[[1]],
                             name =   read_yaml("~/.inwt/rsync/config.yaml")[[2]],
                             password =  read_yaml("~/.inwt/rsync/config.yaml")[[3]],
                             url =   read_yaml("~/.inwt/rsync/config.yaml")[[4]])

  expectTrue <- function(a) testthat::expect_true(a)

  #old

                  #  serverTesting <- connectionL2R(
                  #   host =   read_yaml("~/.inwt/rsync/config.yaml")[[1]],
                  #   name =   read_yaml("~/.inwt/rsync/config.yaml")[[2]],
                  #   password =  read_yaml("~/.inwt/rsync/config.yaml")[[3]],
                  #   url =   read_yaml("~/.inwt/rsync/config.yaml")[[4]]
                  # )

                  # serverTestingOld <- connectionOld(
                  #   host =   read_yaml("~/.inwt/rsync/config.yaml")[[1]],
                  #   name =   read_yaml("~/.inwt/rsync/config.yaml")[[2]],
                  #   password =  read_yaml("~/.inwt/rsync/config.yaml")[[3]],
                  #   url =   read_yaml("~/.inwt/rsync/config.yaml")[[4]]
                  # )


#Tests for L2R

  expectTrue(grepl("rsync://", serverTestingL2R$host))
  expectTrue(is.character(serverTestingL2R$host))
  expectTrue(grepl("https://", serverTestingL2R$url))
  expectTrue(is.character(serverTestingL2R$url))
  expectTrue(is.character(serverTestingL2R$name))



  dirName <- tempdir()
  # In case we run these Tests multiple times in a row:
  file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
  save(list = "y", file = paste0(dirName, "/", "y.Rdata"))

  expectTrue(nrow(listEntries(rsync::deleteAllEntries(serverTestingL2R))) == 0)

  expectTrue(nrow(listEntries(rsync::sendFile(serverTestingL2R, paste0(dirName, "/", "y.Rdata")))) == 1)

  # expectTrue(nrow(listEntries(rsync::sendFile(serverTestingL2R, paste0(dirName, "/", "xy.Rdata")))) == 1)

  expectTrue(nrow(listEntries(rsync::sendFolder(serverTestingL2R, dirName, pattern = "*.Rdata"))) == 2)
  expectTrue(rsync::getEntry(serverTestingL2R, "x.Rdata")$x == 1)

  # validate
  local <- function(file) paste0(dirName, "/", file)
  remote <- function(file) paste0(serverTestingL2R$url, file)

  testthat::expect_warning(
    rsyncSuccessful(local("x.Rdata"), remote("y.Rdata")),
    regexp = "Local and remote file are not the same!"
  )
  testthat::expect_null(unlist(rsyncSuccessful(local("y.Rdata"), remote("y.Rdata"))))

  # delete
  expectTrue(nrow(listEntries(deleteEntry(serverTestingL2R, "x.Rdata"))) == 1)
  expectTrue(nrow(listEntries(deleteAllEntries(serverTestingL2R))) == 0)

  # send two files at once, validate results
  expectTrue(nrow(listEntries(sendFile(serverTestingL2R, paste0(dirName, "/", c("x", "y"), ".Rdata")))) == 2)
  expectTrue(nrow(listEntries(deleteAllEntries(serverTestingL2R))) == 0)

  z <- 3
  expectTrue(nrow(listEntries(sendObject(serverTestingL2R, z))) == 1)
  expectTrue(getEntry(serverTestingL2R, "z.Rdata")$z == 3)
  expectTrue(nrow(listEntries(deleteEntry(serverTestingL2R, "z.Rdata"))) == 0)

  # check for csv
  dat <- data.frame(
    x = 1L,
    date = "2017-01-01",
    z = 1.12345,
    stringsAsFactors = FALSE
  )
  data.table::fwrite(dat, file = paste0(dirName, "/", "dat.csv"))
  expectTrue(nrow(listEntries(sendFile(serverTestingL2R, paste0(dirName, "/", "dat.csv")))) == 1)
  expectTrue(base::identical(dat, getEntry(serverTestingL2R, "dat.csv")))
  expectTrue(nrow(listEntries(deleteAllEntries(serverTestingL2R))) == 0)

  # check for json
  lst <- list(
    x = 1:3,
    date = "2017-01-01"
  )
  jsonlite::write_json(lst, path = paste0(dirName, "/", "lst.json"))
  expectTrue(nrow(listEntries(sendFile(serverTestingL2R, paste0(dirName, "/", "lst.json")))) == 1)
  expectTrue(base::identical(lst, getEntry(serverTestingL2R, "lst.json")))
  expectTrue(nrow(listEntries(deleteAllEntries(serverTestingL2R))) == 0)







#test R2L connection
  #create serverR2LHelper to make sure a file to send exists
  dirName <- tempdir()

  serverR2LHelper <- connection( type = "L2R",
                                 host = serverTestingR2L$host,
                                 name = serverTestingR2L$name,
                                 password = serverTestingR2L$password,
                                 url =   serverTestingR2L$url)


  expectTrue(nrow(listEntries(deleteAllEntries(serverR2LHelper))) == 0)

  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
  save(list = "y", file = paste0(dirName, "/", "y.Rdata"))


  expectTrue(nrow(listEntries(rsync::sendFile(serverR2LHelper, paste0(dirName, "/", "y.Rdata")))) == 1)
  expectTrue(nrow(listEntries(rsync::sendFolder(serverR2LHelper, dirName, pattern = "*.Rdata"))) == 3)



  # #actual test for R2L
  # #Baustelle
  # # expectTrue(nrow(listEntries(rsync::sendFile(serverTestingR2L, paste0(dirName, "/", "y.Rdata")))) == 1)
  # rsync::sendFile(serverTestingR2L, paste0(dirName, "/", "y.Rdata"))
  #
  # #works:
  # rsync::rsync(from = paste0(dirName, "/", "y.Rdata") , to = "~/Netzfreigaben/Git_TEX/PlayWith/SyncDestination/")
  #
  #
  # rsync::sendFile(db = serverTestingR2L, localDir = "~/Netzfreigaben/Git_TEX/PlayWith/SyncDestination/", file = paste0(dirName, "/",  "y.Rdata"))
  # expectTrue(file.exists(file = paste0( "~/Netzfreigaben/Git_TEX/PlayWith/SyncDestination/",  "y.Rdata")))
#
#   expectTrue(nrow(listEntries(rsync::sendFolder(serverTestingR2L, dirName, pattern = "*.Rdata"))) == 2)




