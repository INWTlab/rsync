#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams sendFile
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


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams sendFile
#' @param entryName an entry that will be checked
#'
#' @export
identicalEntries.default <- function(db, entryName, ...) {

  on.exit(try({close(srcFile); close(destFile)}, silent = TRUE))

  srcFile <- file(getSrcFile(db, entryName), open = 'rb')

  if (!is.null(class(db)[1]  == 'RsyncL')) {
    destFile <- file(getDestFile(db, entryName), open = "rb")
  } else {
    stop('function not valid for type rsync deamon')
  }

  if (base::identical(openssl::sha256(srcFile), openssl::sha256(destFile))) {
    message("Rsync successful: Local and host file are identical!")
    TRUE
  } else {
    warning("Src and dest file are not identical!")
    FALSE
  }
}


