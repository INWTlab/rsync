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
loadData <- function(db, ...) {
  UseMethod("loadData", db)
}

#' @export
loadData.default <- function(db, dataName, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  file <-getHostFile(db, dataName)
  to <- tempdir()
  pre <- getPre(db)

  rsync(file, to, args = args, pre = pre)

  if (base::grepl('.Rdata', dataName)) {
    con <- file(paste0(to, '/', dataName), 'rb')
    load(con, e <- new.env(parent = emptyenv()))
    close(con)
    as.list(e, all.names = TRUE)
  } else if (base::grepl('.csv', dataName)) {
    csvName <- data.table::fread(paste0(to, '/', dataName), showProgress = FALSE, data.table = FALSE)
    csvName
  } else if (base::grepl('.json', dataName)) {
    jsonName <- jsonlite::read_json(paste0(to, '/', dataName), simplifyVector = TRUE)
    jsonName
  } else {stop('File of type ', file_ext(dataName), 'not supported.')}
}
