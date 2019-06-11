#' @details
#' \code{sendAllFiles} Sends all files in \code{src} to \code{dest} using \code{sendFile}.
#'
#' @rdname rsync
#' @export
sendAllFiles <- function(db, ...) {
  UseMethod("sendAllFiles", db)
}

#' @rdname rsync
#' @export
sendAllFiles.default <- function(db, verbose = FALSE, ...) {

  args <- if (verbose) "-ltrvvx" else "-ltrx"

  src <- getSrc(db)
  dest <- getDest(db)
  pre <- getPre(db)

  rsynccli(src, dest, args = args, pre = pre)
  db
}

#' @rdname awss3
#' @export
sendAllFiles.awss3 <- function(db, verbose = FALSE, ...) {

  args <- if (!verbose) "--quiet --no-progress --only-show-errors" else ""
  args <- paste("sync", args)

  src <- getSrc(db)
  dest <- getDest(db)
  profile <- getProfile(db)

  awscli(src, dest, args = args, profile = profile)
  db

}
