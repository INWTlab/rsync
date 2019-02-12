#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db rsync object that contains information on the type of connection,
#'     the target directory (remote or local) and eventually a password.
#' @param entryName entry that shall be deleted.
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#' @param ... additional arguments
#'
#' @details
#' \describe{
#' Deletes an entry from a Rsync object.
#' }
#' @export
deleteEntry <- function(db, ...) {
  UseMethod("deleteEntry", db)
}

#' @export
deleteEntry.default <- function(db, entryName, verbose = FALSE) {
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
  to <- db$to
  file <- emptyDir
  rsync(file, to, args = args, pre = pre)
  db
}


