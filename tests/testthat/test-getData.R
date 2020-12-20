context("getData")

testthat::test_that("load data", {

  con <- setupTestEnvironment()

  #csv
  dat <- data.frame(
    x = 1L,
    date = "2018-12-24",
    z = 1.12345,
    stringsAsFactors = FALSE
  )

  data.table::fwrite(dat, file = getSrcFile(con, "dat.csv"))
  sendFile(con, "dat.csv")

  #json
  lst <- list(
    x = 1:3,
    date = "2018-12-24"
  )
  jsonlite::write_json(lst, path = getSrcFile(con, "lst.json"))

  #Rdata
  invisible(removeAllFiles(con))
  invisible(sendFile(con, fileName = 'x.Rdata'))
  testthat::expect_true(nrow(listFiles(con)) == 1)
  rdata <- getData(con, fileName = 'x.Rdata')
  testthat::expect_true(objects(rdata) == "x")
  rm(rdata)
  testthat::expect_true(file.exists(getDestFile(con,'x.Rdata')))

  #csv
  invisible(removeAllFiles(con))
  invisible(sendFile(con, fileName = 'dat.csv'))
  testthat::expect_true(nrow(listFiles(con)) == 1)
  csvData <- getData(con, fileName = 'dat.csv')
  csvData$date <- as.character(csvData$date)
  testthat::expect_true(identical(dat, csvData))

  #json
  invisible(removeAllFiles(con))
  invisible(sendFile(con, fileName = 'lst.json'))
  testthat::expect_true(nrow(listFiles(con)) == 1)
  jsonData <- getData(con, fileName = 'lst.json')
  testthat::expect_true(identical(jsonData, lst))

})

