setupTestEnvironment <- function() {
  randomName <- function() paste0(sample(letters, 10), collapse = "")

  # setup folder
  dirName <- paste0(tempdir(), "/", randomName(), "/")
  dirName2 <- paste0(tempdir(), "/", randomName(), "/")
  dir.create(dirName)
  dir.create(dirName2)

  nestedFolder <- paste0(dirName, "nestedFolder/")
  dir.create(nestedFolder)

  # create some files
  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "x.Rdata"))
  save(list = "y", file = paste0(dirName, "y.Rdata"))

  rsync(
    src = dirName,
    dest = dirName2
  )
}
