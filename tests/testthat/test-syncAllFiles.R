context("syncAllFiles")

test_that("sync all files (with delete)", {
  con <- setupTestEnvironment()

  invisible(removeAllFiles(con))
  ## add extra files and folders into destination
  cat("blah", file = file.path(getDest(con), "extra_file.txt"))
  cat("blah", file = file.path(getDest(con), ".dotfile"))
  cat("blah", file = file.path(getDest(con), "filenodot"))
  dir.create(tempfile(tmpdir = getDest(con)))

  ## send, with no delete
  sendAllFiles(con)
  testthat::expect_true(nrow(listFiles(con)) == 10)

  ## now with delete
  syncAllFiles(con)
  testthat::expect_true(nrow(listFiles(con)) == 6)
})

test_that("sync all files (with delete) on AWS S3", {
  testthat::skip_if(!profileExists("testing"))
  removeFileFromSrc <- function(con, file) {
    file <- paste0(getSrc(con), file)
    unlink(file, recursive = TRUE)
  }
  con <- setupS3TestEnvironment()
  invisible(removeAllFiles(con))

  ## send, with no delete
  sendAllFiles(con)
  testthat::expect_true(nrow(listFiles(con)) == 6)

  ## remove some files and sync
  removeFileFromSrc(con, "nested folder")
  removeFileFromSrc(con, ".y.Rdata")
  removeFileFromSrc(con, "y.Rdata")
  syncAllFiles(con)
  testthat::expect_true(nrow(listFiles(con)) == 3)
})
