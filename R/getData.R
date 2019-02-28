#' @details
#' \code{getData}: sync and load the contents of a file in \code{dest}. This
#' can be a Rdata file or a csv or json. The file will be saved in \code{src}.
#'
#' @rdname rsync
#' @export
getData <- function(db, ...) {
  UseMethod("getData", db)
}

#' @rdname rsync
#' @export
getData.default <- function(db, fileName, verbose = FALSE, ...) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  getFile(db, fileName)
  fileExtension <- tools::file_ext(fileName)
  fullFileName <- getSrcFile(db, fileName)
  fextMethod <- sprintf("load.%s", tolower(fileExtension))
  fextMethod <- try(get(fextMethod, mode = "function"), silent = TRUE)
  if (inherits(fextMethod, "try-error"))
    stop(sprintf("No applicable method for '%s'", fileExtension))
  fextMethod(fullFileName)

}

load.rdata <- function(fileName) {
  on.exit(try(close(con)))
  con <- file(fileName, 'rb')
  load(con, e <- new.env(parent = emptyenv()))
  as.list(e, all.names = TRUE)
}

load.csv <- function(fileName) {
  data.table::fread(fileName, showProgress = FALSE, data.table = FALSE)
}

load.json <- function(fileName) {
  jsonlite::read_json(fileName, simplifyVector = TRUE)
}
