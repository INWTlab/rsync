#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams sendFile
#'
#' @details
#' \describe{
#'   Loads a rdata file from a Rsync object.
#' }
#' @export
loadData <- function(db, ...) {
  UseMethod("loadData", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams sendFile
#' @param dataName name of data file
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#' @export
loadData.default <- function(db, dataName, verbose = FALSE, ...) {

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
  } else {stop('File of type ', tools::file_ext(dataName), 'not supported.')}
}
