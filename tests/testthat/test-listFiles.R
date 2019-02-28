context("listFiles")

test_that("Entries rsyncL objects can be listet", {

  con <- setupTestEnvironment()

  invisible(removeAllFiles(con))
  invisible(sendFile(con, fileName = 'x.Rdata'))
  invisible(sendFile(con, fileName = 'y.Rdata'))
  testthat::expect_true(nrow(listFiles(con)) == 2)
  invisible(removeAllFiles(con))
  testthat::expect_true(nrow(listFiles(con)) == 0)

})
