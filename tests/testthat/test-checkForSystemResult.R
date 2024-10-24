testthat::context("checkSystemResult")

test_that("checkSystemResult with intern = TRUE and successful command", {
  command <- "true"
  intern <- TRUE
  status <- system(command, intern = intern, wait = TRUE)
  result <- checkSystemResult(status)

  expect_is(status, "character")
  expect_is(result, "character")
  expect_equal(result, status)
})

test_that("checkSystemResult with intern = FALSE and successful command", {
  command <- "true"
  intern <- FALSE
  status <- system(command, intern = intern, wait = TRUE)
  result <- checkSystemResult(status)

  expect_is(status, "integer")
  expect_is(result, "integer")
  expect_equal(result, status)
})

test_that("checkSystemResult with intern = TRUE and failing command", {
  command <- "false"
  intern <- TRUE

  expect_warning(
    status <- system(command, intern = intern, wait = TRUE)
  )
  expect_error(checkSystemResult(status))
  expect_is(status, "character")
  expect_equal(attr(status, "status"), 1)
})

test_that("checkSystemResult with intern = FALSE and failing command", {
  command <- "false"
  intern <- FALSE

  status <- system(command, intern = intern, wait = TRUE)
  expect_error(checkSystemResult(status))
  expect_is(status, "integer")
  expect_equal(status, 1)
})
