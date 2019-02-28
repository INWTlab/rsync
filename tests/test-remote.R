dockerVersion <- system("docker --version", intern = TRUE)
if (grepl("docker: command not found", dockerVersion)) {
  cat("Docker is not available for testing. Stop here.")
  q(save = "no")
}

system("bash test-remote.sh", wait = FALSE)
Sys.sleep(2)

library("rsync")
con <- rsync(
  "rsync://user@localhost:8000/volume",
  tempdir(),
  password = "pass"
)
x <- 1
dat <- listFiles(sendObject(con, x))
stopifnot(nrow(dat) == 1)
Sys.sleep(8)
