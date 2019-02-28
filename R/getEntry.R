#' @details
#' \describe{
#'   \code{getFile} downloads a file from a Rsync object. If validate is TRUE
#'   the hash-sum of the remote file is compared to the local version. A warning
#'   is issued should they differ.
#' }
#'
#' @rdname rsync
#' @export
getFile <- function(db, ...) {
  UseMethod("getFile", db)
}


#' @rdname rsync
#' @export
getFile.default <- function(db, fileName, validate = TRUE, verbose = FALSE, ...) {

  args <- if (verbose == TRUE) "-ltvvx" else "-ltx"

  file <- getDestFile(db, fileName)
  to <- getSrc(db)
  pre <- getPre(db)

  rsynccli(file, to, args = args, pre = pre)

  if (validate) identicalEntries(db, fileName)

  db
}
