#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db rsync object that contains information on the type of connection,
#'     the target directory (remote or local) and eventually a password.
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

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams sendFile
#' @param fileName file, which shall be sent to a target directory
#' @param validate TRUE. validates if entryName is identical in both locations.
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#' @export
sendFile.default <- function(db, fileName, validate = FALSE, verbose = FALSE, ...) {

  args <- if (verbose == TRUE) "-ltvvx" else "-ltx"

  file <- getSrcFile(db,fileName)
  to <- getDest(db)
  pre <- getPre(db)

  rsynccli(file, to, args = args, pre = pre)

  if (validate) identicalEntries(db, fileName)
  db

}
