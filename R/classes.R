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
#' @rdname rsync-class
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


getFile <- function(db, fileName) {
  from <- getwd()
  file <- paste0(from, '/' ,basename(fileName))
  file
}


getTo <- function(db) {
  type <- getType(db)
  if(type == 'RsyncL') db$to
  else if(type == 'RsyncDHTTP') {to <- paste0(db$host, db$name)}
  else if(type == 'RsyncD') {to <- paste0(db$host, db$name)}
  else stop("Failed to construct destination folder. 'to' or 'host' are missing.")
}


getObj <- function(db) {
  if(!is.null(db$host))  paste0(db$host, db$name)
  else if(!is.null(db$to)) db$to
  else stop("Failed to find Object to list")
}


getType <- function(db) {
  type <-class(db)[1]
  type
}

