library(yaml)
library(testthat)

context("RsyncServer")


serverTestingRsyncDHTTP <- rsync::connection( type = "RsyncDHTTP",
                       host =   read_yaml("~/.inwt/rsync/config.yaml")[[1]],
                       name =   read_yaml("~/.inwt/rsync/config.yaml")[[2]],
                       password =  read_yaml("~/.inwt/rsync/config.yaml")[[3]],
                       url =   read_yaml("~/.inwt/rsync/config.yaml")[[4]])



serverTestingRsyncD <- rsync::connection( type = "RsyncD",
                             host =   read_yaml("~/.inwt/rsync/config.yaml")[[1]],
                             name =   read_yaml("~/.inwt/rsync/config.yaml")[[2]],
                             password =  read_yaml("~/.inwt/rsync/config.yaml")[[3]],
                             url =  "" ) #read_yaml("~/.inwt/rsync/config.yaml")[[4]]

  expectTrue <- function(a) testthat::expect_true(a)


#Tests for RsyncDHTTP

  expectTrue(grepl("rsync://", serverTestingRsyncDHTTP$host))
  expectTrue(is.character(serverTestingRsyncDHTTP$host))
  expectTrue(grepl("https://", serverTestingRsyncDHTTP$url))
  expectTrue(is.character(serverTestingRsyncDHTTP$url))
  expectTrue(is.character(serverTestingRsyncDHTTP$name))



  dirName <- tempdir()
  # In case we run these Tests multiple times in a row:
  file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
  save(list = "y", file = paste0(dirName, "/", "y.Rdata"))

  expectTrue(nrow(listEntries(rsync::deleteAllEntries(serverTestingRsyncDHTTP))) == 0)

  expectTrue(nrow(listEntries(rsync::sendFile(serverTestingRsyncDHTTP, paste0(dirName, "/", "y.Rdata")))) == 1)

  # expectTrue(nrow(listEntries(rsync::sendFile(serverTestingRsyncDHTTP, paste0(dirName, "/", "xy.Rdata")))) == 1)

  expectTrue(nrow(listEntries(rsync::sendFolder(serverTestingRsyncDHTTP, dirName, pattern = "*.Rdata"))) == 2)
  expectTrue(rsync::getEntry(serverTestingRsyncDHTTP, "x.Rdata")$x == 1)

  # validate
  local <- function(file) paste0(dirName, "/", file)
  remote <- function(file) paste0(serverTestingRsyncDHTTP$url, file)

  testthat::expect_warning(
    rsyncSuccessful(local("x.Rdata"), remote("y.Rdata")),
    regexp = "Local and remote file are not the same!"
  )
  testthat::expect_null(unlist(rsyncSuccessful(local("y.Rdata"), remote("y.Rdata"))))

  # delete
  expectTrue(nrow(listEntries(deleteEntry(serverTestingRsyncDHTTP, "x.Rdata"))) == 1)
  expectTrue(nrow(listEntries(deleteAllEntries(serverTestingRsyncDHTTP))) == 0)

  # send two files at once, validate results
  expectTrue(nrow(listEntries(sendFile(serverTestingRsyncDHTTP, paste0(dirName, "/", c("x", "y"), ".Rdata")))) == 2)
  expectTrue(nrow(listEntries(deleteAllEntries(serverTestingRsyncDHTTP))) == 0)

  z <- 3
  expectTrue(nrow(listEntries(sendObject(serverTestingRsyncDHTTP, z))) == 1)
  expectTrue(getEntry(serverTestingRsyncDHTTP, "z.Rdata")$z == 3)
  expectTrue(nrow(listEntries(deleteEntry(serverTestingRsyncDHTTP, "z.Rdata"))) == 0)

  # check for csv
  dat <- data.frame(
    x = 1L,
    date = "2017-01-01",
    z = 1.12345,
    stringsAsFactors = FALSE
  )
  data.table::fwrite(dat, file = paste0(dirName, "/", "dat.csv"))
  expectTrue(nrow(listEntries(sendFile(serverTestingRsyncDHTTP, paste0(dirName, "/", "dat.csv")))) == 1)
  expectTrue(base::identical(dat, getEntry(serverTestingRsyncDHTTP, "dat.csv")))
  expectTrue(nrow(listEntries(deleteAllEntries(serverTestingRsyncDHTTP))) == 0)

  # check for json
  lst <- list(
    x = 1:3,
    date = "2017-01-01"
  )
  jsonlite::write_json(lst, path = paste0(dirName, "/", "lst.json"))
  expectTrue(nrow(listEntries(sendFile(serverTestingRsyncDHTTP, paste0(dirName, "/", "lst.json")))) == 1)
  expectTrue(base::identical(lst, getEntry(serverTestingRsyncDHTTP, "lst.json")))
  expectTrue(nrow(listEntries(deleteAllEntries(serverTestingRsyncDHTTP))) == 0)







#test RsyncD connection
  #small mistake as in ls function


  #create serverRsyncDHelper to make sure a file to send exists
  dirName <- tempdir()

  serverRsyncDHelper <- connection( type = "RsyncDHTTP",
                                 host = serverTestingRsyncD$host,
                                 name = serverTestingRsyncD$name,
                                 password = serverTestingRsyncD$password,
                                 url =   "")


  expectTrue(nrow(listEntries(deleteAllEntries(serverRsyncDHelper))) == 0)

  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
  save(list = "y", file = paste0(dirName, "/", "y.Rdata"))


  expectTrue(nrow(listEntries(rsync::sendFile(serverRsyncDHelper, paste0(dirName, "/", "y.Rdata")))) == 1)
  expectTrue(nrow(listEntries(rsync::sendFolder(serverRsyncDHelper, dirName, pattern = "*.Rdata"))) == 3)



#####
#make the section for RsyncLL first
  dirName <- tempdir()
  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
  save(list = "y", file = paste0(dirName, "/", "y.Rdata"))

  serverTestingRsyncL <- rsync::connection( type = "RsyncL",
                                            from = paste0(dirName, "/", "x.Rdata"),
                                            to = paste0(dirName, "/", "neu/"))


  #delete all Entries:
  expectTrue(length(listEntries(rsync::deleteAllEntries(serverTestingRsyncL))) == 0)
  #sendFile
  expectTrue(length(listEntries(rsync::sendFile(serverTestingRsyncL))) == 1)


  #sendFolder
  serverTestingRsyncL$from <- paste0(dirName, "/", "y.Rdata")
  expectTrue(length(listEntries(rsync::sendFile(serverTestingRsyncL))) == 2)
  expectTrue(length(listEntries(rsync::sendFolder(serverTestingRsyncL, dirName, pattern = "*.Rdata"))) == 2)  #here length instead of nrow neccessary

  #get
  expectTrue(rsync::getEntry(serverTestingRsyncL, "y.Rdata")$y == 2)







#Baustelle

########
#tests for rsyncD

  dirName <- tempdir()
  # In case we run these Tests multiple times in a row:
  file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
  save(list = "y", file = paste0(dirName, "/", "y.Rdata"))

  # expectTrue(nrow(listEntries(rsync::deleteAllEntries(serverTestingRsyncD))) == 0)
  # expectTrue(nrow(listEntries(rsync::sendFile(serverTestingRsyncDHTTP, paste0(dirName, "/", "y.Rdata")))) == 1)

  #Baustelle:
#list files
  to <- "/home/dberscheid/Netzfreigaben/Git_TEX/PlayWith/SyncDestination"
  system(paste("ls", to))


#sende Datei von ordner zu R deamon
  sendFile(serverTestingRsyncD, file = "/home/dberscheid/Netzfreigaben/Git_TEX/PlayWith/SyncDestination/Testfile2.R")

  listEntries(serverTestingRsyncD)

  command <- " RSYNC_PASSWORD=\"usf8atgsat7865Gzd.sfrsr52ru\" rsync -av /home/dberscheid/Netzfreigaben/Git_TEX/PlayWith/SyncDestination/Testfile2.R rsync://tipico-rsync@inwt-vmeh2.inwt.de/Sports-Testing"

  system(command, intern = FALSE, wait = TRUE, ignore.stdout = FALSE, ignore.stderr = FALSE)



#sende Datei zurück
  command <- " RSYNC_PASSWORD=\"usf8atgsat7865Gzd.sfrsr52ru\" rsync  -rtv  rsync://tipico-rsync@inwt-vmeh2.inwt.de/Sports-Testing/y.Rdata /home/dberscheid/Netzfreigaben/Git_TEX/PlayWith/SyncDestination"
  system(command, intern = FALSE, wait = TRUE, ignore.stdout = FALSE, ignore.stderr = FALSE)


  rsync::sendFile((serverTestingRsyncD, paste0(dirName, "/", "y.Rdata")))

  rsync::deleteAllEntries((serverTestingRsyncD))

  length(listEntries(serverTestingRsyncD)) == 1 #listEntries is working



