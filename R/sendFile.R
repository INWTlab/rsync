#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#'
#' @details
#' \describe{
#'   Sends a file to a rsync host object.
#' }
#' @export
sendFile <- function(host, ...) {
  UseMethod("sendFile", host)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param local local directory to send file from
#' @param host  Rsync object , returning: 'name', 'lastModified' and 'size'
#' @param fileName file to be sent (i.e .txt file, .R file, etc.)
#' @param verbose (logical) default: FALSE
#'
#' @details
#' \describe{
#'   Sends a file (file in local file system) to a host.
#' }
#'
#' @export
sendFile.default <- function(host, local, fileName, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  direction <- 'send'
    rsyncFile(local, host, fileName, direction, args)

}


