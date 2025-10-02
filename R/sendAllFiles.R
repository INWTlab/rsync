#' @details
#' \code{sendAllFiles} Sends all files in \code{src} to \code{dest} using \code{sendFile}.
#'
#' @rdname rsync
#' @export
sendAllFiles <- function(db, ...) {
  UseMethod("sendAllFiles", db)
}

#' @rdname rsync
#' @export
sendAllFiles.default <- function(db, ...) {
  sendFile(db, fileName = ".", ...)
}

#' @rdname awss3
#' @export
sendAllFiles.awss3 <- function(db, verbose = FALSE, ...) {
  args <- if (!verbose) "--quiet --no-progress --only-show-errors" else ""
  args <- paste("sync", args)

  src <- getSrc(db)
  dest <- getDest(db)
  profile <- getProfile(db)
  endpoint_url <- db$endpoint_url

  awscli(src, dest, args = args, profile = profile, endpoint_url = endpoint_url)
  db
}
