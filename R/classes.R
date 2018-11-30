#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param host (character) the url, where the host file is stored
#' @param name (character) the name of the target server
#' @param password (character) the password to the corresponding target server
#' @param url (character) the url to the corresponding target server
#'
#' @details
#' \describe{
#'  Establishes a connection with a Rsync HTTP server. All arguments are characters.
#' }
#' @export
rsyncDHTTP <-function(host, name, password, url) {
  host <- paste0(sub("/$", "", host), "/")
  name <- sub("^/", "", name)
  url <- paste0(sub("/$", "", url), "/")
  aoos::retList(c("RsyncDHTTP", "RsyncD"))
}

#' @rdname rsync-class
#' @export
rsyncD <-function(host, name, password) {
  host <- paste0(sub("/$", "", host), "/")
  name <- sub("^/", "", name)
  aoos::retList("RsyncD")
}


#' @rdname rsync-class
#' @export
rsyncL <-function(from, to) {
  aoos::retList(c("RsyncL", "RsyncD"))
}


getPre <- function(db) {
  if (!is.null(db$password)) {
    sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  } else {
    NULL
  }
}

getTo <- function(db) {
  if (!is.null(db$to)) db$to
  else if (!is.null(db$host)) paste0(db$host, db$name)
  else stop("Failed to construct destination folder. 'to' or 'host' are missing.")
}
