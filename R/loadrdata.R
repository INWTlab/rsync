#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#'
#' @param host Rsync object, with csv file
#' @param csvName name of csv file
#' @param ...
#'
#' @details
#' \describe{
#'   loads a rdata file from a Rsync object.
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

  type <- getType(db)
  if (type == 'RsyncL') {
    from <-db$to
  } else {
    from <- paste0(db$host, db$name)
  }

  file <- paste0(from, '/' ,basename(rdataName))
  to <- getwd()
  pre <- getPre(db)

  rsync(file, to, args = args, pre = pre)

  #load rdata after downloading from local directory
  con <- file(paste0(to, '/', rdataName), 'rb')
  load(con, e <- new.env(parent = emptyenv()))
  close(con)
  as.list(e, all.names = TRUE)

}
