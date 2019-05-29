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

library("rsync")
withSystemCall({
  ## rsyncd
  con <- rsync(
    "rsync://user@localhost:8000/volume",
    tempdir(),
    password = "pass")
  x <- 1
  dat <- listFiles(sendObject(con, x))
  stopifnot(nrow(dat) == 1)

  ## sshd
  Sys.setenv(RSYNC_RSH="ssh -i./docker-root -oStrictHostKeyChecking=no -p20011")
  con <- rsync(
    "root@localhost:~",
    tempdir()
  )
  x <- 1
  dat <- listFiles(sendObject(con, x))
  stopifnot("x.Rdata" %in% dat$name)
})
