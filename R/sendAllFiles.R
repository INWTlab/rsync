#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams sendFile
#'
#' @details
#' \describe{
#'   Sends the content of a folder to db using \code{sendFile}. \code{validate} and \code{verbose} are as in
#'   \code{sendFile}.
#' }
#'
#' @export
sendAllFiles <- function(db, ...) {
  UseMethod("sendAllFiles", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams sendFile
#' @param folderName folder, of which the content shall be sent
#' @param validate TRUE. validates if entryName is identical in both locations.
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#' @export
sendAllFiles.default <- function(db, validate = FALSE, verbose = FALSE, ...) {
  src <- getSrc(db)
  files <- listFiles(rsync(dest = getSrc(db)))
  files <- files$name
  invisible(lapply(files, sendFile, db = db, verbose = verbose, validate = validate))
  db
}
