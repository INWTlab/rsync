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
sendFile <- function(host, ...) {
  UseMethod("sendFile", host)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object , returning: 'name', 'lastModified' and 'size'
#' @param file file to be sent (i.e .txt file, .R file, etc.)
#' @param validate (logical) default: TRUE,
#' @param verbose (logical) default: FALSE
#'
#' @details
#' \describe{
#'   Sends a file (file in local file system) to db. If validate is TRUE the
#'   hash-sum of the remote file is compared to the local version. A warning is
#'   issued should the differ. The return status of the command line rsync is
#'   returned by this function.
#' }
#'
#' @export
sendFile.default <- function(host, local, fileName, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}


  direction <- 'send'

  #eigentlich:
  #ohne lapply:
    rsyncFile(local, host, fileName, direction, args)

  #alt
  # lapply(filename, rsyncFile, from = local, to = host, args = args)

}


