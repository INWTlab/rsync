#' \describe{
#' Deletes an entry.
#' }
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

  fileName <- basename(fileName)

  args <- if (verbose) "-rvv --delete" else "-r --delete"
  includes <- paste(paste0("--include", " \"", fileName, "\""), collapse = " ")
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


