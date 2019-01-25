#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db rsync object that contains information on the type of connection, the target directory (remote or local) and eventually a password.
#' @param csvName name of csv file
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#' @param ... additional arguments
#'
#' @details
#' \describe{
#'   Loads a csv file from a Rsync object.
#' }
#' @export
loadcsv <- function(db, ...) {
  UseMethod("loadcsv", db)
}

#' @export
loadcsv.default <- function(db, csvName, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  file <-getHostFile(db, csvName)
  to <- tempdir()
  pre <- getPre(db)

  rsync(file, to, args = args, pre = pre)

  csvName <- data.table::fread(paste0(to, '/', csvName), showProgress = FALSE, data.table = FALSE)
  csvName
  }
