context("sendFile")

test_that("send file", {
    con <- setupTestEnvironment()

    withCleanDest <- function(expr) {
        invisible(removeAllFiles(con))
        on.exit({
            invisible(removeAllFiles(con))
        })
        expr
    }

    withCleanDest({
        sendFile(con, "x.Rdata")
        testthat::expect_true(nrow(listFiles(con)) == 1)
    })

    withCleanDest({
        sendFile(con, ".x.Rdata")
        testthat::expect_true(nrow(listFiles(con)) == 1)
    })

    withCleanDest({
        testthat::expect_error(sendFile(con, "__aa__.Rdata"), "file.exists")
        testthat::expect_true(nrow(listFiles(con)) == 0)
    })
})
