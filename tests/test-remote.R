dockerVersion <- try(system("docker --version", intern = TRUE))
if (inherits(dockerVersion, "try-error") || grepl("docker .* not found", dockerVersion)) {
  cat("Docker is not available for testing. Stop here.")
  q(save = "no")
}

withSystemCall <- function(expr) {
  system("bash startup-remote.sh")
  on.exit(system("bash shutdown-remote.sh"))
  expr
}

checkLength <- function(con, n) {
  stopifnot(nrow(rsync::listFiles(con)) == n)
}

tempFolder <- function() {
  tmp <- tempdir()
  dir.create(tmp <- paste0(tmp, "/rsync-test"), FALSE)
  file.remove(dir(tmp, full.names = TRUE))
  tmp
}

library("rsync")
withSystemCall({
  ## rsyncd
  con <- rsync(
    "rsync://user@localhost:8000/volume",
    tempFolder(),
    password = "pass")
  checkLength(rsync::removeAllFiles(con), 0)
  x <- 1
  checkLength(sendObject(con, x), 1)
  y <- 2
  checkLength(sendObject(con, y), 2)
  checkLength(rsync::removeAllFiles(con), 0)
  checkLength(rsync::sendAllFiles(con), 2)

  ## rsyncd password in file
  writeLines("pass", ".pass")
  con <- rsync(
    "rsync://user@localhost:8000/volume",
    tempFolder(),
    password = ".pass")
  checkLength(rsync::removeAllFiles(con), 0)
  x <- 1
  dat <- listFiles(sendObject(con, x))
  stopifnot(nrow(dat) == 1)
  unlink(".pass")
  unlink(tempFolder())

  ## sshd
  con <- rsync(
    "root@localhost:~",
    tempFolder(),
    ssh = "ssh -i./docker-root -oStrictHostKeyChecking=no -p20011"
  )
  x <- 1
  dat <- listFiles(sendObject(con, x))
  stopifnot("x.Rdata" %in% dat$name)
  unlink(tempFolder())

  ## sshd + rsyncd
  con <- rsync(
    "user@localhost::volume",
    password = "pass",
    tempFolder(),
    sshProg = "ssh -i./docker-root -oStrictHostKeyChecking=no -p20012 -l root localhost nc %H 873"
  )
  checkLength(rsync::removeAllFiles(con), 0)
  x <- 1
  dat <- listFiles(sendObject(con, x))
  stopifnot("x.Rdata" %in% dat$name)
  unlink(tempFolder())

})
