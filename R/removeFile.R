#' \code{removeFile} Remove a file from \code{dest}.
#'
#' @rdname rsync
#' @export
removeFile <- function(db, ...) {
  UseMethod("removeFile", db)
}

#' @rdname rsync
#' @export
removeFile.default <- function(db, fileName, verbose = FALSE, ...) {
  if (length(fileName) == 0) return(db)

  on.exit(try(file.remove(emptyDir), silent = TRUE))
  emptyDir <- paste0(tempdir(), "/empty/")
  dir.create(emptyDir)

  args <- if (verbose) "-rvv --delete" else "-r --delete"
  args <- paste(args, getArgs(db))
  pre <- getPre(db)
  to <- getDest(db)
  file <- emptyDir

  rsynccli(file, to, includes = fileName, excludes = "*", args = args, pre = pre)
  db

}


