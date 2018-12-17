#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#'
#' @details
#' \describe{
#'   Sends a file to or from a Rsync object.
#' }
#' @export
getFile <- function(db, ...) {
  UseMethod("getFile", db)
}


#' @export
getFile.default <- function(db, entryName, path = getwd(), validate = TRUE, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}


  direction <- 'get'

  #eigentlich:
  #ohne lapply:
  rsyncFile(local, host, fileName, direction, args)

  #alt
  # lapply(filename, rsyncFile, from = local, to = host, args = args)

}


### TODO:
getFile.rsyncDHTTP <- function(...) {
  download.file(...)
}
