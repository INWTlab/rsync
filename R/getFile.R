#' @details
#' \code{getFile} downloads a file from dest and saves it in src.
#'
#' @rdname rsync
#' @export
getFile <- function(db, ...) {
  UseMethod("getFile", db)
}

#' @rdname rsync
#' @export
getFile.default <- function(db, fileName, validate = FALSE, verbose = FALSE, ...) {

  args <- if (verbose) "-ltvvx" else "-ltx"

  file <- getDestFile(db, fileName)
  to <- getSrc(db)
  pre <- getPre(db)

  rsynccli(file, to, args = args, pre = pre)

  if (validate) validateFile(db, fileName)

  db
}

#' @rdname awss3
#' @export
getFile.awss3 <- function(db, fileName, validate = FALSE, verbose = FALSE, ...) {

  args <- if (!verbose) "--quiet --no-progress --only-show-errors" else ""
  args <- paste("sync ", args)

  dest <- getDest(db)
  src <- getSrc(db)
  profile <- getProfile(db)

  awscli(dest, src, args = args, excludes = "*", includes = fileName, profile = profile)

  if (validate) validateFile(db, fileName)

  db
}
