context("removeAllFiles")

test_that("remove all files", {

  con <- setupTestEnvironment()

  invisible(sendFile(con, fileName = 'x.Rdata'))
  invisible(sendFile(con, fileName = 'y.Rdata'))
  testthat::expect_true(!is.null(listFiles(con)))
  invisible(removeAllFiles(con))
  testthat::expect_true(nrow(listFiles(con)) == 0)

})


