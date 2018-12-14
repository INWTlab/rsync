library(testthat)
library(tidyr)

context("rsyncFile")
source("~/.inwt/rsync/config.R")

expectTrue <- function(a) testthat::expect_true(a)


dirName <- tempdir()
# In case we run these Tests multiple times in a row:
file.remove(dir(dirName, "Rdata|csv|json", full.names = TRUE))
x <- 1
y <- 2
#save(list = "x", file = paste0(dirName, "/", "x.Rdata"))
save(list = "y", file = paste0(dirName, "/", "y.Rdata"))



serverTestingRsyncDHTTP <- rsync::rsyncDHTTP(host = hostURL,
                                             name = nameServer,
                                             password = passwordServer,
                                             url = urlServer)



serverTestingRsyncD <- rsync::rsyncD(host = hostURL,
                                     name = nameServer,
                                     password =passwordServer)



serverTestingRsyncL <- rsync::rsyncL(from = dirName,
                                     to = "/home/dberscheid/Netzfreigaben/Git_TEX/rsync")




  #1) send and get with rsyncDHTTP
  rsync::rsyncFile(local = dirName, host = serverTestingRsyncDHTTP, fileName = 'x.Rdata', direction = 'get', args = "-ltx") # das wäre der get Fall
  rsync::rsyncFile(local = dirName, host = serverTestingRsyncDHTTP, fileName = 'x.Rdata', direction = 'send', args = "-ltx") # das wäre der get Fall
#"/home/dberscheid/Netzfreigaben/Git_TEX/rsync"
  #2:send and get with rsyncD
  rsync::rsyncFile(local = "/home/dberscheid/Netzfreigaben/Git_TEX/rsync", host = serverTestingRsyncD, fileName = 'x.Rdata', direction = 'get', args = "-ltx") # das wäre der get Fall
  #gibt es laut schema nicht
  # rsync::rsyncFile(local = "/home/dberscheid/Netzfreigaben/Git_TEX/rsync", host = serverTestingRsyncD, fileName = 'x.Rdata', direction = 'send', args = "-ltx") # das wäre der get Fall

#3: send and get with rsyncL
  # rsync::rsyncFile(local = "/home/dberscheid/Netzfreigaben/Git_TEX/rsync", host = serverTestingRsyncL, fileName = 'x.Rdata', direction = 'get', args = "-ltx") # das wäre der get Fall
  rsync::rsyncFile(local = "/home/dberscheid/Netzfreigaben/Git_TEX", host = serverTestingRsyncL, fileName = 'y.Rdata', direction = 'send', args = "-ltx") # das wäre der get Fall


