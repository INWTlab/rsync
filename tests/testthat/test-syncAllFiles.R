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
  testthat::expect_true(nrow(listFiles(con)) == 9)

  ## now with delete
  syncAllFiles(con)
  testthat::expect_true(nrow(listFiles(con)) == 5)
})
