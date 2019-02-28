#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams sendFile
#'
#' @details
#' \describe{
#'   Gets a file from a Rsync object. If validate is TRUE the
#'   hash-sum of the remote file is compared to the local version. A warning is
#'   issued should they differ.
#' }
#' @export
getFile <- function(db, ...) {
  UseMethod("getFile", db)
}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams sendFile
#' @param entryName an entry that the get function will get, located on the
#'     rsync deamon side / the local target directory.
#' @param validate validates if entryName is identical in both locations.
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#' @export
getFile.default <- function(db, entryName, validate = TRUE, verbose = FALSE, ...) {

  args <- if (verbose == TRUE) "-ltvvx" else "-ltx"

  file <- getDestFile(db, entryName)
  to <- getSrc(db)
  pre <- getPre(db)

  rsynccli(file, to, args = args, pre = pre)

  if (validate) identicalEntries(db, entryName)

  db
}
