#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param from (character) the working directory, if not specified otherwise
#' @param host (character) the address to the rsync deamon. NULL for a local
#'     rsync connection.
#' @param name (character) the name of the deamon's directory. NULL for a local
#'     rsync connection.
#' @param to (character) a directory, if it is a local rsync connection.
#' @param password (character) the password to the corresponding target server.
#'
#' @details
#' \describe{
#'  Establishes a rsync connection with a local directory or a rsync deamon. All
#'      arguments are characters.
#' }
#' @rdname rsync-class
#' @export
newRsync <- function(from = getwd(), host = NULL, name = NULL, to = paste0(host, name), password = NULL) {
  if (is.null(password)) {
    aoos::retList("RsyncL")
  } else {
    aoos::retList("RsyncD")
  }
}

getPre <- function(db) {
  if (!is.null(db$password)) {
    sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  } else {
    NULL
  }
}

getHostFile <- function(db, fileName) {
  file <- paste0(db$to, '/', basename(fileName))
  file
}

getLocalFile <- function(db, fileName) {
  file <- paste0(db$from, '/', basename(fileName))
  file
}

getObj <- function(db) {
  if (!is.null(db$host))  paste0(db$host, db$name)
  else if (!is.null(db$to)) db$to
  else stop("Failed to find Object to list")
}

