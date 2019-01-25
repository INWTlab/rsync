#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db rsync object that contains information on the type of connection, the target directory (remote or local) and eventually a password.
#' @param fileName file, which shall be sent to a target directory
#' @param validate TRUE. validates if entryName is identical in both locations.
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#' @param ... additional arguments
#'
#' @details
#' \describe{
#'   Sends a file to a rsync object. If validate is TRUE the
#'   hash-sum of the remote file is compared to the local version. A warning is
#'   issued should they differ.
#' }
#' @export
sendFile <- function(db, ...) {
  UseMethod("sendFile", db)
}


#' @export
sendFile.default <- function(db, fileName, validate = TRUE, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  file <- getLocalFile(db,fileName)
  to <- db$to
  pre <- getPre(db)

  rsync(file, to, args = args, pre = pre)

  if ((validate) & (class(db)[1] != 'RsyncD')) identicalEntries(db, fileName)
}
