#' @details
#' \code{removeAllFiles} remove all entries from \code{dest}. \code{src} will
#' not be affected.
#'
#' @rdname rsync
#' @export
removeAllFiles <- function(db, ...) {
  UseMethod("removeAllFiles", db)
}

#' @rdname rsync
#' @export
removeAllFiles.default <- function(db, verbose = FALSE, ...) {
  dat <- listFiles(db)
  entries <- dat$name
  lapply(entries, removeFile, db = db, verbose = verbose)
  db

}
