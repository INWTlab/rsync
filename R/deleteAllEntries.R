#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams sendFile
#'
#' @details
#' \describe{
#' Deletes all entries from a rsync object.
#' }
#' @export
deleteAllEntries <- function(db, ...) {
  UseMethod("deleteAllEntries", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams sendFile
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#'
#' @details
#' \describe{
#' Deletes all entries from a rsync object.
#' }
#' @export
deleteAllEntries.default <- function(db, verbose = FALSE, ...) {

  on.exit(try(file.remove(emptyDir), silent = TRUE))

  if(verbose == TRUE) args <-  "-rvv --delete"
  else args <- "-r --delete"

  dat <- listEntries(db)
  entries <- c(levels(dat$name))

  invisible(lapply(entries, deleteEntry, db = db, verbose = verbose))
  listEntries(db)
}
