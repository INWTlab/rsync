#' @details
#' \describe{
#'   \code{removeAllFiles} deletes all entries from a rsync object.
#' }
#'
#' @rdname rsync
#' @export
removeAllFiles <- function(db, ...) {
  UseMethod("removeAllFiles", db)
}

#' @rdname rsync
#' @export
removeAllFiles.default <- function(db, verbose = FALSE, ...) {

  if(verbose == TRUE) args <-  "-rvv --delete"
  else args <- "-r --delete"

  dat <- listFiles(db)
  entries <- dat$name

  lapply(entries, removeFile, db = db, verbose = verbose)
  db

}
