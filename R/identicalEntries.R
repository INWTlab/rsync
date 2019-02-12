#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db rsnc connection object
#' @param entryName an entry that will be checked
#' @param ... additional arguments
#'
#' @details
#' \describe{
#' Tests if two files are exactly identical. It returns TRUE in this case,
#'     FALSE in every other case.
#' }
#'
#'
#' @export
identicalEntries <- function(db, ...) {
  UseMethod("identicalEntries", db)
}

#' @export
identicalEntries.default <- function(db, entryName) {

  on.exit(try({close(locFile); close(hostFile)}, silent = TRUE))

  locFile <- file(paste0(db$from, '/', entryName), open = 'rb')

  if (!is.null(class(db)[1]  == 'RsyncL')) {
    hostFile <- file(paste0(db$to,'/', entryName), open = "rb")
  } else {
    stop('function not valid for type rsync deamon')
  }

  if (base::identical(openssl::sha256(locFile), openssl::sha256(hostFile))) {
    print("Rsync successful: Local and host file are identical!")
  } else {
    warning("Local and host file are not identical!")
  }
}


