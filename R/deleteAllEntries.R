#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db rsync object that contains information on the type of connection, the target directory (remote or local) and eventually a password.
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#' @param ... further arguments
#'
#' @details
#' \describe{
#' Deletes all entries from a rsync object.
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
