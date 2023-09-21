context("validateFile")

testthat::test_that("validate identical entries", {

  con <- setupTestEnvironment()
  existingTempDirectories <- list.files(tempdir(), pattern = "[[:alpha:]]{8}")

  removeAllFiles(con)
  sendFile(con, fileName = 'x.Rdata')
  testthat::expect_true(nrow(listFiles(con)) == 1)
  testthat::expect_message(testthat::expect_true(
    validateFile(con, fileName = 'x.Rdata')))

  con1 <- con
  con1$src <- paste0(tempdir(), "/")
  x <- 1234
  sendObject(con1, x)
  testthat::expect_warning(
    validateFile(con, fileName = "x.Rdata"),
    "Src and dest file are not identical!"
  )

  # This test needs at least some documentation. We encountered an issue with already existing
  # directoris when running dir.create(db1$src) in validateFile. So, we are calling unlink in the
  # exit code of validateFile. To ensure that the directory has been removed, we would usually call
  # dir.exists but we don't know the path name as the directory was created inside of validateFile.
  # So, we store all the directories inside of tempdir before we call validateFile and do the same
  # at the end of the test. If the directory was actually unlinked, we expect the set of
  # directories inside tempdir to remain unchanged.
  testthat::expect_identical(
    existingTempDirectories,
    list.files(tempdir(), pattern = "[[:alpha:]]{8}")
  )
})

