context("getFile")

testthat::test_that("get files", {
  con <- setupTestEnvironment()

  testthat::expect_true(nrow(listFiles(removeAllFiles(con))) == 0)
  sendFile(con, fileName = "x.Rdata")
  testthat::expect_true(nrow(listFiles(con)) == 1)
  testthat::expect_true(file.remove(getSrcFile(con, "x.Rdata")))
  getFile(con, fileName = "x.Rdata")
  testthat::expect_true(file.exists(getSrcFile(con, "x.Rdata")))

  invisible(sendAllFiles(con))
  getFile(con, fileName = "nested folder/y.Rdata")
})
