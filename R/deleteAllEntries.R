#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param host Rsync object
#' @param ...
#'
#' @details
#' \describe{
#' deletes all entries from a Rsync object
#' }
#' @export
deleteAllEntries <- function(db, ...) {
  UseMethod("deleteAllEntries", db)
}

#' @export
deleteAllEntries.default <- function(db, verbose = FALSE) {

  on.exit(try(file.remove(emptyDir), silent = TRUE))

  if(verbose == TRUE) args <-  "-rvv --delete"
  else args <- "-r --delete"

  dat <- rsync::listEntries(db)
  entries <- c(levels(dat$name))

  invisible(lapply(entries, deleteEntry, db = db, verbose = verbose))
  rsync::listEntries(db)

}
