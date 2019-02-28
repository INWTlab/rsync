context("getFile")

testthat::test_that("get files", {
  con <- setupTestEnvironment()

  testthat::expect_true(nrow(removeAllFiles(con)) == 0)
  sendFile(con, fileName = 'x.Rdata')
  testthat::expect_true(nrow(listFiles(con)) == 1)
  testthat::expect_true(file.remove(paste0(con$src, "x.Rdata")))
  getFile(con, entryName = 'x.Rdata')
  testthat::expect_true(file.exists(paste0(con$src, '/','x.Rdata')))

})
