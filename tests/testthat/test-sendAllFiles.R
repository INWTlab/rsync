context("sendAllFiles")

test_that("send all files", {
  con <- setupTestEnvironment()

  invisible(removeAllFiles(con))

  sendAllFiles(con)
  testthat::expect_true(nrow(listFiles(con)) == 5)
})

test_that("send all files with delete", {
  con <- setupTestEnvironment()

  invisible(removeAllFiles(con))
  ## add extra files and folders into destination
  cat("blah", file = file.path(getDest(con), "extra_file.txt"))
  cat("blah", file = file.path(getDest(con), ".dotfile"))
  cat("blah", file = file.path(getDest(con), "filenodot"))
  dir.create(tempfile(tmpdir = getDest(con)))

  sendAllFiles(con)
  testthat::expect_true(nrow(listFiles(con)) == 9)

  sendAllFiles(con, delete = TRUE)
  testthat::expect_true(nrow(listFiles(con)) == 5)
})
