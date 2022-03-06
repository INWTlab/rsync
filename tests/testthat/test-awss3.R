testthat::context("awss3")

testthat::test_that("create data", {
  testthat::skip_if(!profileExists("testing"))
  con <- setupS3TestEnvironment()
  on.exit(try(removeAllFiles(con)))

  invisible(try(removeAllFiles(con)))
  invisible(sendAllFiles(con))
  testthat::expect_equal(sum(is.na(listFiles(con)$lastModified)), 3)
  testthat::expect_equal(sum(!is.na(listFiles(con)$lastModified)), 3)
  testthat::expect_equal(nrow(listFiles(con)), 6)
  testthat::expect_equal(getData(con, "x.Rdata"), list(x = 1))
  testthat::expect_equal(getData(con, "nestedFolder/y.Rdata"), list(y = 2))
  testthat::expect_equal(getData(con, "nested folder/y.Rdata"), list(y = 2))
  testthat::expect_equal(getData(con, "nested  folder/y.Rdata"), list(y = 2))
  z <- 1
  invisible(sendObject(con, z))
  testthat::expect_equal(nrow(listFiles(con)), 7)
  testthat::expect_equal(nrow(listFiles(con, recursive = TRUE)), 7)
  testthat::expect_equal(sum(!is.na(listFiles(con, recursive = TRUE)$lastModified)), 7)
  testthat::expect_equal(nrow(listFiles(removeAllFiles(con))), 0)
})
