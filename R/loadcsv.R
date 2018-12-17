#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#'
#' @param host Rsync object, with csv file
#' @param csvName name of csv file
#' @param ...
#'
#' @details
#' \describe{
#'   loads a csv file from a Rsync object.
#' }
#' @export
loadcsv <- function(host, ...) {
  UseMethod("loadcsv", host)
}


#' @export
loadcsv.default <- function(host, csvName, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  direction <- 'get'
  dirName <- tempdir()
  rsyncFile(dirName, host, csvName, direction, args)

  #open csv file in dirName
  csvName <- data.table::fread(paste0(dirName, '/', csvName), showProgress = FALSE, data.table = FALSE)
  csvName
  }


