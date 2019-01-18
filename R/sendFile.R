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
sendFile <- function(db, ...) {
  UseMethod("sendFile", db)
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
sendFile.default <- function(db, fileName, validate = TRUE, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  file <- getFile(db, fileName)
  to <- getTo(db)
  pre <- getPre(db)

  rsync(file, to, args = args, pre = pre)

  type <-getType(db)
  if ((validate) & (type != 'RsyncD')) identicalEntries(db, fileName)
}
