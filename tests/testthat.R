library("rsync")

if (requireNamespace("testthat", quietly = TRUE)) {
  testthat::test_check("rsync")
}
