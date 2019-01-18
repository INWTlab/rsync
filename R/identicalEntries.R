#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param localFile source file
#' @param remoteFile target file
#'
#' @details
#' \describe{
#' Tests if two files are exactly identical. It returns TRUE in this case, FALSE in every other case.
#' }
#'
#'
#' @export
identicalEntries <- function(db, ...) {
  UseMethod("identicalEntries", db)
}


#' @export
identicalEntries.default <- function(db, entryName) {

  on.exit({try(silent = TRUE, {close(locFile); close(hostFile)})})
  locFile <- file(paste0(getwd(), '/', entryName), open = 'rb')

  type <- getType(db)

  if(type == 'RsyncDHTTP') {
    hostFile <- url(paste0(db$url, entryName), open = "rb")
  } else if(!is.null(type == 'RsyncL')) {
    hostFile <- file(paste0(db$to, entryName), open = "rb")
  } else {
    stop('function not valid for type rsync deamon')
  }

  if (base::identical(openssl::sha256(locFile), openssl::sha256(hostFile))) {
    print("Rsync successful: Local and host file are identical!")
  } else {
    warning("Local and host file are not identical!")
  }
}


