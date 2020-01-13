testthat::context("as.character")

testthat::test_that("as.character", {
  testthat::expect_equal(
    as.character(rsync(dest = "rsync://test", src = "/", password = "1234")),
    c(dest = "rsync://test", src = "/", password = "****", ssh = "NULL", sshProg = "NULL")
  )
})
