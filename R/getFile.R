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
getFile <- function(host, ...) {
  UseMethod("getFile", host)
}


#' @export
getFile.default <- function(local, host, fileName, validate = TRUE, verbose = FALSE ) {

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


