#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db rsync object that contains information on the type of connection, the target directory (remote or local) and eventually a password.
#' @param folder folder, of which the content shall be sent
#' @param validate TRUE. validates if entryName is identical in both locations.
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#' @param ... additional arguments
#'
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

#' @export
sendFolder.default <- function(db, folderName, validate = TRUE, verbose = FALSE ) {

    if (verbose == TRUE) {
      args <- "-ltvvx"
    } else {
      args <- "-ltx"}

    dat <- listDir(paste0(tempdir(), '/', folderName))
    entries <- c(levels(dat$Objects))
    invisible(lapply(entries, sendFile, db = db, verbose = verbose))
}
