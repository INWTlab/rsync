context("identicalEntries")

testthat::test_that("validate identical entries", {
  con <- setupTestEnvironment()

  removeAllFiles(con)
  sendFile(con, fileName = 'x.Rdata')
  testthat::expect_true(nrow(listFiles(con)) == 1)
  identicalEntries(con, entryName = 'x.Rdata')

})
