#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param x Rsync object
#' @param ... additional arguments
#'
#' @details
#' \describe{
#' prints the Rsync object
#' }
#'
#' @export
print.RsyncD <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  print(listEntries(x), ...)
}


#' @inheritParams  print.RsyncD
#' @export
print.RsyncL <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  print(listEntries(x), ...)
}

#' @inheritParams  print.RsyncD
#' @export
as.character.RsyncD <- function(x, ...) {
  x$password <- "****"
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}

#' @inheritParams  print.RsyncD
#' @export
as.character.RsyncL <- function(x, ...) {

  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param dirName directory name
#'
#' @details
#' \describe{
#' lists the objects in a directory
#' }
#'
#' @export
listDir <- function(dirName) {
  dat <- base::list.files(dirName)
  dat <- as.data.frame(dat[grepl("Rdata|csv|json", dat)])
  names(dat) <- "Objects"
  dat

}
