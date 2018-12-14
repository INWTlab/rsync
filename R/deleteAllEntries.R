#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#'
#' @details
#' \describe{
#' deletes an entry from a Rsync object
#' }
#' @export
deleteAllEntries <- function(host, ...) {
  UseMethod("deleteAllEntries", host)
}

#' @export
deleteAllEntries.default <- function(host, verbose = FALSE) {

  on.exit(try(file.remove(emptyDir), silent = TRUE))

  if(verbose == TRUE) args <-  "-rvv --delete"
  else args <- "-r --delete"

  dat <- rsync::listEntries(host)
  entries <- c(levels(dat$name))

  invisible(lapply(entries, deleteEntry, host = host, verbose = verbose))
  rsync::listEntries(host)

}


