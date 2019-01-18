#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object , returning: 'name', 'lastModified' and 'size'
#' @param folder folder, of which the content shall be sent
#' @param ... more arguments
#' @param validate (logical) default = TRUE
#' @param verbose (logical) default = TRUE
#'
#'
#' @details
#' \describe{
#'   Sends the content of a folder to db using \code{sendFile}. \code{...} are
#'   passed to \link{dir}. \code{validate} and \code{verbose} are as in
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
#' @param db Rsync object , returning: 'name', 'lastModified' and 'size'
#' @param folder folder, of which the content shall be sent
#' @param ... more arguments
#' @param validate (logical) default = TRUE
#' @param verbose (logical) default = TRUE
#'
#'
#' @details
#' \describe{
#'   Sends the content of a folder to db using \code{sendFile}. \code{...} are
#'   passed to \link{dir}. \code{validate} and \code{verbose} are as in
#'   \code{sendFile}.
#' }
#' @export
sendFolder.default <- function(db, folderName, validate = TRUE, verbose = FALSE ) {

    if (verbose == TRUE) {
      args <- "-ltvvx"
    } else {
      args <- "-ltx"}

    dat <- listDir(paste0(getwd(), '/', folderName))
    entries <- c(levels(dat$Objects))
    invisible(lapply(entries, sendFile, db = db, verbose = verbose))
}
