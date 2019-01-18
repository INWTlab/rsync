#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param host Rsync object, with json file
#' @param jsonName name of json file
#' @param ...
#'
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
loadjson.default <- function(db, jsonName, verbose = FALSE ) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  type <- getType(db)

  if (type == 'RsyncL') {
    from <-db$to
  } else {
    from <- paste0(db$host, db$name)
  }

  file <- paste0(from, '/' ,basename(jsonName))
  to <- getwd()
  pre <- getPre(db)

  rsync(file, to, args = args, pre = pre)

  jsonName <- jsonlite::read_json(paste0(dirName, '/', jsonName), simplifyVector = TRUE)
  jsonName
}


