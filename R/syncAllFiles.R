#' @details
#' \code{syncAllFiles} Syncs all files in \code{src} to \code{dest}. Files that exist in \code{dest} but not in \code{src} will be deleted.
#'
#' @rdname rsync
#' @export
syncAllFiles <- function(db, ...) {
  UseMethod("syncAllFiles", db)
}

#' @rdname rsync
#' @export
syncAllFiles.default <- function(db, verbose = FALSE, ...) {
  args <- if (verbose) "-ltrvvx" else "-ltrx"
  args <- paste(args, "--delete")

  src <- paste0(getSrc(db), ".")
  dest <- getDest(db)
  pre <- getPre(db)

  rsynccli(src, dest, args = args, pre = pre)
  db
}

#' @rdname awss3
#' @export
syncAllFiles.awss3 <- function(db, verbose = FALSE, ...) {
  args <- if (!verbose) "--quiet --no-progress --only-show-errors" else ""
  args <- paste("sync", args, "--delete")

  src <- getSrc(db)
  dest <- getDest(db)
  profile <- getProfile(db)
  endpoint_url <- db$endpoint_url

  awscli(src, dest, args = args, profile = profile, endpoint_url = endpoint_url)
  db
}
