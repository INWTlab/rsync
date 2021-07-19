testthat::context("awss3")

setupS3TestEnvironment <- function() {
  randomName <- function() paste0(sample(letters, 10), collapse = "")

  # setup folder
  dirName <- paste0(tempdir(), "/", randomName(), "/")
  dir.create(dirName)
  nestedFolder <- paste0(dirName, "nestedFolder/")
  dir.create(nestedFolder)

  # create some files
  x <- 1
  y <- 2
  save(list = "x", file = paste0(dirName, "x.Rdata"))
  save(list = "y", file = paste0(dirName, "y.Rdata"))
  save(list = "y", file = paste0(nestedFolder, "y.Rdata"))

  awss3(
    src = dirName,
    dest = "s3://inwt-testing",
    profile = "testing"
  )
}

testthat::test_that("create data", {
  testthat::skip_if(!profileExists("testing"))
  con <- setupS3TestEnvironment()
  on.exit(try(removeAllFiles(con)))

  invisible(sendAllFiles(con))
  testthat::expect_equal(nrow(listFiles(con)), 3)
  testthat::expect_equal(getData(con, "x.Rdata"), list(x = 1))
  testthat::expect_equal(getData(con, "nestedFolder/y.Rdata"), list(y = 2))
  z <- 1
  invisible(sendObject(con, z))
  testthat::expect_equal(nrow(listFiles(con)), 4)
  testthat::expect_equal(nrow(listFiles(removeAllFiles(con))), 0)
})
