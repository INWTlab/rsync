
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
loadjson <- function(host, ...) {
  UseMethod("loadjson", host)
}


#' @export
loadjson.default <- function(host, jsonName, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  direction <- 'get'

  dirName <- tempdir()

  rsyncFile(dirName, host, jsonName, direction, args)

  jsonName <- jsonlite::read_json(paste0(dirName, '/', jsonName), simplifyVector = TRUE)
  jsonName
}


