context("listFiles")

test_that("list entries in dest", {
  con <- setupTestEnvironment()

  invisible(removeAllFiles(con))
  invisible(sendFile(con, fileName = "x.Rdata"))
  invisible(sendFile(con, fileName = "y.Rdata"))
  testthat::expect_true(nrow(listFiles(con)) == 2)
  invisible(removeAllFiles(con))
  testthat::expect_true(nrow(listFiles(con)) == 0)

  testthat::expect_output(dat <- print(con))
  testthat::expect_identical(dat, con)
})
