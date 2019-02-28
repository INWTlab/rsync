#' API for the CLI program rsync
#'
#' Setup a rsync configuration. The configuration object can be used for access
#' to a folder.
#'
#' @param dest (character) the address to the rsync daemon or a folder.
#' @param src (character) a folder.
#' @param password (character|NULL) a password in case a rsync daemon is used.
#' @param db (rsync) an object of class 'rsync' initialized with \code{rsync}.
#' @param fileName (character) a file name that exists in \code{src}
#' @param validate (logical) if the file in dest and src should be validated
#'   using a sha256 check sum.
#' @param verbose (logical) if we use 'vorbose' as option in the cli.
#' @param object (ANY) any R object you wish to store.
#' @param objectName (character) the name used to store the object. The file
#'   extension will always be a 'Rdata'.
#' @param ... arguments passed to methods.
#'
#' @details
#' \code{rsync} is a command line tool. For details see
#'   \url{https://rsync.samba.org/}.
#'
#' @rdname rsync
#' @export
rsync <- function(dest, src = getwd(), password = NULL) {
  stopifnot(
    is.character(dest) && length(dest) == 1,
    is.character(src) && length(src) == 1,
    is.null(password) || is.character(password) && length(password) == 1
  )
  ret <- list(
    dest = dest,
    src = src,
    password = password
  )
  class(ret) <- "rsync"
  ret
}

getPre <- function(db) {
  if (!is.null(db$password)) {
    sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  } else {
    NULL
  }
}

getDestFile <- function(db, fileName) {
  paste0(sub("/+$", "", db$dest), '/', fileName)
}

getSrcFile <- function(db, fileName) {
  paste0(sub("/+$", "", db$src), '/', fileName)
}

getDest <- function(db) db$dest
getSrc <- function(db) db$src

#' @export
print.rsync <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  print(listFiles(x), ...)
}

#' @export
as.character.rsync <- function(x, ...) {
  if (!is.null(x$password)) x$password <- "****"
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}
