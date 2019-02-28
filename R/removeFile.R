#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams removeAllFiles
#'
#' @details
#' \describe{
#' Deletes an entry from a Rsync object.
#' }
#' @export
removeFile <- function(db, ...) {
  UseMethod("removeFile", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams removeAllFiles.default
#' @param entryName entry that shall be deleted.
#'
#' @export
removeFile.default <- function(db, entryName, verbose = FALSE, ...) {
  if (length(entryName) == 0) return(db)

  on.exit(try(file.remove(emptyDir), silent = TRUE))

  entryName <- basename(entryName)

  args <- if (verbose) "-rvv --delete" else "-r --delete"
  includes <- paste(paste0("--include", " \"", entryName, "\""), collapse = " ")
  excludes <- "--exclude \"*\""
  args <- paste(args, includes, excludes)

  emptyDir <- paste0(tempdir(), "/empty/")
  dir.create(emptyDir)

  pre <- getPre(db)
  to <- getDest(db)
  file <- emptyDir
  rsynccli(file, to, args = args, pre = pre)
  db

}


