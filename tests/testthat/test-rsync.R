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



#####
#make the section for RsyncLL first
  dirName <- tempdir()
  #remove all files from directory at the beginning
  suppressWarnings(if (length(list.files(dirName)) != 0) file.remove(paste0(dirName, "/", list.files(dirName))))

  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
  save(list = "y", file = paste0(dirName, "/", "y.Rdata"))


  #nur zum testen:
  # dirName <- "/home/dberscheid/Netzfreigaben/Git_TEX/PlayWith/SyncDestination"

  dir.create(file.path(dirName, "neu/"), showWarnings = FALSE)
  neu <- file.path(dirName, "neu/")

  serverTestingRsyncL <- rsync::connection( type = "RsyncL",
                                            from = paste0(dirName, "/", "x.Rdata"),
                                            to = neu)



  #delete all Entries:
  expectTrue(nrow(listEntries(rsync::deleteAllEntries(serverTestingRsyncL))) == 0)
  #sendFile
  expectTrue(nrow(listEntries(rsync::sendFile(serverTestingRsyncL))) == 1)


  #sendFolder
  serverTestingRsyncL$from <- paste0(dirName, "/", "y.Rdata")
  expectTrue(nrow(listEntries(rsync::sendFile(serverTestingRsyncL))) == 2)
  expectTrue(nrow(listEntries(rsync::deleteAllEntries(serverTestingRsyncL))) == 0)
  expectTrue(nrow(listEntries(rsync::sendFolder(serverTestingRsyncL, dirName, pattern = "*.Rdata"))) == 2)
  #get
  expectTrue(rsync::getEntry(serverTestingRsyncL, "y.Rdata")$y == 2)


  #sendObject
  z <- 3
  expectTrue(nrow(listEntries(sendObject(serverTestingRsyncL, z))) == 3) #warum wird y.Rdata statt z.Rdata gesendet?

  expectTrue(getEntry(serverTestingRsyncL, "z.Rdata")$z == 3)
  expectTrue(nrow(listEntries(deleteEntry(serverTestingRsyncL, "z.Rdata"))) == 2)
  expectTrue(nrow(listEntries(rsync::deleteAllEntries(serverTestingRsyncL))) == 0)



  # check for csv
  dat <- data.frame(
    x = 1L,
    date = "2017-01-01",
    z = 1.12345,
    stringsAsFactors = FALSE
  )
  data.table::fwrite(dat, file = paste0(dirName, "/", "dat.csv"))
  expectTrue(nrow(listEntries(sendFile(serverTestingRsyncL, paste0(dirName, "/", "dat.csv")))) == 1)
  expectTrue(base::identical(dat, getEntry(serverTestingRsyncL, "dat.csv")))
  expectTrue(nrow(listEntries(deleteAllEntries(serverTestingRsyncL))) == 0)

  # check for json
  lst <- list(
    x = 1:3,
    date = "2017-01-01"
  )
  jsonlite::write_json(lst, path = paste0(dirName, "/", "lst.json"))
  expectTrue(nrow(listEntries(sendFile(serverTestingRsyncL, paste0(dirName, "/", "lst.json")))) == 1)
  expectTrue(base::identical(lst, getEntry(serverTestingRsyncL, "lst.json")))
  expectTrue(nrow(listEntries(deleteAllEntries(serverTestingRsyncL))) == 0)


#Baustelle


  #test RsyncD connection



  #create serverRsyncDHelper to make sure a file to send exists
# dirName <- tempdir()


  serverRsyncDHelper <- connection( type = "RsyncDHTTP",
                                    host = serverTestingRsyncD$host,
                                    name = serverTestingRsyncD$name,
                                    password = serverTestingRsyncD$password,
                                    url =   serverTestingRsyncDHTTP$url)


  expectTrue(nrow(listEntries(deleteAllEntries(serverRsyncDHelper))) == 0)

  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
  save(list = "y", file = paste0(dirName, "/", "y.Rdata"))

  #small mistake as in ls function
  expectTrue(nrow(listEntries(rsync::sendFile(serverRsyncDHelper, paste0(dirName, "/", "y.Rdata")))) == 1)
  expectTrue(nrow(listEntries(rsync::sendFolder(serverRsyncDHelper, dirName, pattern = "*.Rdata"))) == 3)


#zu diesem Zeitpunkt sind 3 Datein auf rsync
  expectTrue(nrow(listEntries(serverTestingRsyncDHTTP)) == 3)

#jetzt dateien von rsync zu localer Dir senden:

dirName <- "/home/dberscheid/Netzfreigaben/Git_TEX/PlayWith/SyncDestination"

    nrow(listEntries(rsync::sendFile(serverTestingRsyncD, "z.Rdata", to = dirName))) #funktioniert

listEntries(serverTestingRsyncD)


  # expectTrue(nrow(listEntries(rsync::deleteAllEntries(serverTestingRsyncD))) == 0)





  #ALTER Teil der Baustelle:

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



