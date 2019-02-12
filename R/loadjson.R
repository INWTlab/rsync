#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db rsync object that contains information on the type of connection,
#' the target directory (remote or local) and eventually a password.
#' @param jsonName name of json file
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#' @param ... additional arguments
#'
#' @details
#' \describe{
#'   Loads a file from a Rsync object.
#' }
#' @export
loadjson <- function(db, ...) {
  UseMethod("loadjson", db)
}


#' @export
loadjson.default <- function(db, jsonName, verbose = FALSE) {

  args <- if (verbose) "-ltvvx" else "-ltx"

  file <- getHostFile(db, jsonName)
  to <- tempdir()
  pre <- getPre(db)

  rsync(file, to, args = args, pre = pre)

  jsonName <- jsonlite::read_json(
    paste0(to, '/', jsonName),
    simplifyVector = TRUE
  )

  jsonName
}


