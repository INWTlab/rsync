context("removeFile")

testthat::test_that("Removing files", {

  con <- setupTestEnvironment()

  #rsyncD
  invisible(removeAllFiles(con))
  testthat::expect_true(nrow(listFiles(con)) == 0)
  invisible(sendFile(con, fileName = 'y.Rdata'))
  testthat::expect_true(nrow(listFiles(con)) == 1)
  invisible(removeFile(con, fileName = 'y.Rdata'))
  testthat::expect_true(nrow(listFiles(con)) == 0)

})

