#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db rsync object that contains information on the type of connection, the target directory (remote or local) and eventually a password.
#' @param rdataName name of rdata file
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#' @param ... additional arguments
#'
#' @details
#' \describe{
#'   Loads a rdata file from a Rsync object.
#' }
#' @export
loadrdata <- function(db, ...) {
  UseMethod("loadrdata", db)
}

#' @export
loadrdata.default <- function(db, rdataName, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  file <-getHostFile(db, rdataName)
  to <- tempdir()
  pre <- getPre(db)

  rsync(file, to, args = args, pre = pre)

  con <- file(paste0(to, '/', rdataName), 'rb')
  load(con, e <- new.env(parent = emptyenv()))
  close(con)
  as.list(e, all.names = TRUE)

}
