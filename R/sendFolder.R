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
sendFolder <- function(db, ...) {
  UseMethod("sendFolder", db)
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
sendFolder.default <- function(db, folderName, validate = TRUE, verbose = FALSE, ...) {

  dat <- listDir(paste0(tempdir(), '/', folderName))
  entries <- levels(dat$Objects)
  invisible(lapply(entries, sendFile, db = db, verbose = verbose))
  listEntries(db)

}
