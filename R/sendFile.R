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

  args <- if (verbose == TRUE) "-ltvvx" else "-ltx"

  file <- getSrcFile(db,fileName)
  to <- getDest(db)
  pre <- getPre(db)

  rsynccli(file, to, args = args, pre = pre)

  if (validate) validateFile(db, fileName)
  db

}
