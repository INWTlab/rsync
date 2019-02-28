#' @details \describe{
#' \code{sendObject} sends an object (from the environment)
#'   to a rsync target. This abstracts a pattern where you would use \link{save}
#'   followed by \code{sendFile}. The reverse is done using \code{getObject}
#' }
#'
#' @rdname rsync
#' @export
sendObject <- function(db, ...) {
  UseMethod("sendObject", db)
}

#' @rdname rsync
#' @export
sendObject.default <- function(db, object, objectName = as.character(substitute(object)), validate = FALSE, verbose = FALSE, ...) {

  args <- if (verbose) "-ltvvx" else "-ltx"
  assign(objectName, object)
  fileName <- paste0(objectName, ".Rdata")
  save(
    list = objectName,
    file =  file <- getSrcFile(db, fileName),
    compress = TRUE
  )
  sendFile(db, fileName, validate = validate, verbose = verbose, ...)

}
