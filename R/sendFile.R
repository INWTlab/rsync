#' @details
#' \code{sendFile} Sends a file to a rsync object.
#'
#' @rdname rsync
#' @export
sendFile <- function(db, ...) {
  UseMethod("sendFile", db)
}

#' @rdname rsync
#' @export
sendFile.default <- function(db, fileName, validate = FALSE, verbose = FALSE, ...) {
  stopifnot(length(fileName) == 1)

  args <- if (verbose == TRUE) "-ltrvvx" else "-ltrx"
  args <- paste(args, getArgs(db))
  src <- paste0(getSrc(db), fileName)
  dest <- getDest(db)
  pre <- getPre(db)

  rsynccli(src, dest, args = args, pre = pre)

  if (validate) validateFile(db, fileName)
  db
}

#' @rdname awss3
#' @export
sendFile.awss3 <- function(db, fileName, validate = FALSE, verbose = FALSE, ...) {
  args <- if (!verbose) "--quiet --no-progress --only-show-errors" else ""
  args <- paste("sync", args)

  src <- getSrc(db)
  dest <- getDest(db)
  profile <- getProfile(db)

  awscli(src, dest, args = args, excludes = "*", includes = fileName, profile = profile)

  if (validate) validateFile(db, fileName)
  db
}
