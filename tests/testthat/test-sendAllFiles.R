context("sendAllFiles")

test_that("send all files", {

  con <- setupTestEnvironment()

  invisible(removeAllFiles(con))

  sendAllFiles(con)
  testthat::expect_true(nrow(listFiles(con)) == 3)

})
