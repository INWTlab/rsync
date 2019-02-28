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

  args <- if (verbose == TRUE) "-ltvvx" else "-ltx"

  file <- getDestFile(db, fileName)
  to <- getSrc(db)
  pre <- getPre(db)

  rsynccli(file, to, args = args, pre = pre)

  if (validate) validateFile(db, fileName)

  db
}
