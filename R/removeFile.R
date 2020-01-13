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

#' @rdname awss3
#' @export
removeFile.awss3 <- function(db, fileName, verbose = FALSE, ...) {
  if (length(fileName) == 0) return(db)

  dest <- getDest(db)
  profile <- getProfile(db)
  if (!isS3Bucket(dest)) return(NextMethod())

  on.exit(try(file.remove(src), silent = TRUE))
  src <- paste0(tempdir(), "/empty/")
  dir.create(src)

  args <- if (!verbose) "--quiet --no-progress --only-show-errors" else ""
  args <- paste("sync --delete", args)

  awscli(src, dest, includes = fileName, excludes = "*", args = args, profile = profile)
  db

}
