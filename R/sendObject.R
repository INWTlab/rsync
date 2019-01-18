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
sendObject <- function(db, ...) {
  UseMethod("sendObject", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object , returning: 'name', 'lastModified' and 'size'
#' @param file file to be sent (i.e .txt file, .R file, etc.)
#' @param validate (logical) default: TRUE,
#' @param verbose (logical) default: FALSE
#'
#' @details
#' \describe{
#'   Sends a file (file in local file system) to db. If validate is TRUE the
#'   hash-sum of the remote file is compared to the local version. A warning is
#'   issued should the differ. The return status of the command line rsync is
#'   returned by this function.
#' }
#'
#' @export
sendObject.default <- function(db, object, objectName = as.character(substitute(object)), validate = TRUE, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  assign(objectName, object)

  # dirName <- tempdir()
  dirName <- getwd()

  save(list = objectName, file =  file <- paste0(dirName, "/", objectName, ".Rdata"), compress = TRUE)
  to <- getTo(db)
  pre <- getPre(db)

  rsync(file, to, args = args, pre = pre)

  type <-getType(db)
  if ((validate) & (type != 'RsyncD')) identicalEntries(db, paste0(objectName, '.Rdata'))
}
