#' Rsync API
#'
#' Setup a rsync configuration. The configuration object can be used for remote
#' or src access to a folder. For available methods, see the 'seeAlso' section
#' of this documentation.
#'
#' @param src (character) the working directory, if not specified otherwise
#' @param dest (character) the address to the rsync deamon. NULL for a
#'   src rsync connection.
#' @param password (character|NULL) the password to the corresponding target
#'   server.
#'
#' @details
#' \code{rsync} is a command line tool. For details see
#'   \url{https://rsync.samba.org/}.
#' @seealso \link{getFile}, \link{removeFile}, \link{listFiles},
#'   \link{sendFile}, \link{sendFolder}, \link{sendObject}
#'
#' @rdname rsync-class
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
