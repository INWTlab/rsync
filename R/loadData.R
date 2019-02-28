#' @details
#' \code{loadData}: sync and load the contents of a file in \code{dest}. This
#' can be a Rdata file or a csv or json. The file will be saved in \code{src}.
#'
#' @rdname rsync
#' @export
loadData <- function(db, ...) {
  UseMethod("loadData", db)
}

#' @rdname rsync
#' @export
loadData.default <- function(db, fileName, verbose = FALSE, ...) {

  if (verbose == TRUE) {
    args <- "-ltvvx"
  } else {
    args <- "-ltx"}

  file <- getDestFile(db, fileName)
  to <- tempdir()
  pre <- getPre(db)

  rsynccli(file, to, args = args, pre = pre)

  if (base::grepl('\\.Rdata$', fileName)) {
    con <- file(paste0(to, '/', fileName), 'rb')
    load(con, e <- new.env(parent = emptyenv()))
    close(con)
    as.list(e, all.names = TRUE)
  } else if (base::grepl('\\.csv$', fileName)) {
    csvName <- data.table::fread(paste0(to, '/', fileName), showProgress = FALSE, data.table = FALSE)
    csvName
  } else if (base::grepl('\\.json$', fileName)) {
    jsonName <- jsonlite::read_json(paste0(to, '/', fileName), simplifyVector = TRUE)
    jsonName
  } else {stop('File of type ', tools::file_ext(fileName), 'not supported.')}
}
