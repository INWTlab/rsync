context("identicalEntries")

testthat::test_that("validate identical entries", {

  con <- setupTestEnvironment()

  removeAllFiles(con)
  sendFile(con, fileName = 'x.Rdata')
  testthat::expect_true(nrow(listFiles(con)) == 1)
  testthat::expect_message(testthat::expect_true(
    identicalEntries(con, fileName = 'x.Rdata')))

  con1 <- con
  con1$src <- paste0(tempdir(), "/")
  x <- 1234
  sendObject(con1, x)
  testthat::expect_warning(
    identicalEntries(con, fileName = "x.Rdata"),
    "Src and dest file are not identical!"
  )

})
