#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param x Rsync object
#' @param ... more arguments
#'
#' @details
#' \describe{
#' prints the Rsync object
#' }
#'
#' @export
print.RsyncServer <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  print(listEntries(x), ...)
}


#' @export
print.RsyncDHTTP <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  print(listEntries(x), ...)
}


#' @export
print.RsyncD <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  print(listEntries(x), ...)
}


#' @export
print.RsyncL <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  print(listEntries(x), ...)
}



#' @export
as.character.RsyncServer <- function(x, ...) {
  x$password <- "****"
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}


#' @export
as.character.RsyncDHTTP <- function(x, ...) {
  x$password <- "****"
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}


#' @export
as.character.RsyncD <- function(x, ...) {
  x$password <- "****"
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}


#' @export
as.character.RsyncL <- function(x, ...) {

  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}



#' @export
listDir <- function(dirName) {
  dat <- list.files(dirName)
  dat <- as.data.frame(dat[grepl("Rdata|csv|json", dat)])
  names(dat) <- "Objects"
  dat

}
