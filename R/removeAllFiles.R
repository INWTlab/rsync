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
removeAllFiles <- function(db, ...) {
  UseMethod("removeAllFiles", db)
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
removeAllFiles.default <- function(db, verbose = FALSE, ...) {

  if(verbose == TRUE) args <-  "-rvv --delete"
  else args <- "-r --delete"

  dat <- listFiles(db)
  entries <- c(levels(dat$name)) # TODO

  invisible(lapply(entries, removeFile, db = db, verbose = verbose))
  db

}
