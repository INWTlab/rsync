context("sendObject")

test_that("sending Objects for rsyncL is working", {
  con <- setupTestEnvironment()

  z <- 1

  invisible(removeAllFiles(con))
  sendObject(db = con, object = z)
  testthat::expect_true(nrow(listFiles(con)) == 1)
  invisible(removeAllFiles(db = con))

})
