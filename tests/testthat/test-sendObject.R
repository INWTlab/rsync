context("sendObject")

test_that("sending Objects for rsyncL is working", {
  con <- setupTestEnvironment()
  invisible(removeAllFiles(con))
  z <- 1
  sendObject(db = con, object = z, validate = TRUE)
  testthat::expect_true(nrow(listFiles(con)) == 1)
  invisible(removeAllFiles(db = con))
})
