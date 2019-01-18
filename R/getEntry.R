#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#'
#' @details
#' \describe{
#'   Sends a file to or from a Rsync object.
#' }
#' @export
getEntry <- function(db, ...) {
  UseMethod("getEntry", db)
}


#' @export
getEntry.default <- function(db, entryName, validate = TRUE, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  from <- paste0(db$host, db$name)
  file <- paste0(from, '/' ,basename(entryName))
  to <- getwd()
  pre <- getPre(db)

  rsync(file, to, args = args, pre = pre)

  type <-getType(db)
  if ((validate) & (type != 'RsyncD')) identicalEntries(db, entryName)
}
