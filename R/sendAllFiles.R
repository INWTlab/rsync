#' @details
#' \describe{
#'   \code{sendAllFiles} Sends all files in src to dest using \code{sendFile}.
#' }
#'
#' @rdname rsync
#' @export
sendAllFiles <- function(db, ...) {
  UseMethod("sendAllFiles", db)
}

#' @rdname rsync
#' @export
sendAllFiles.default <- function(db, validate = FALSE, verbose = FALSE, ...) {
  src <- getSrc(db)
  files <- listFiles(rsync(dest = getSrc(db)))
  files <- files$name
  invisible(lapply(files, sendFile, db = db, verbose = verbose, validate = validate))
  db
}
