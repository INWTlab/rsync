#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param localFile source file
#' @param remoteFile target file
#'
#' @details
#' \describe{
#' Tests if the sync process was successful. It returns TRUE in this case, FALSE in every other case.
#' }
#'
#'
#' @export
rsyncSuccessful <- function(host, ...) {
  UseMethod("rsyncSuccessful", host)
}


#' @export
rsyncSuccessful <- function(local, host, filenName) {
  # locFile
  # mapply(identicalEntries, localFile = localFile, hostFile = hostFile)
}


