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


getPre <- function(host) {
  if (!is.null(host$password)) {
    sprintf("RSYNC_PASSWORD=\"%s\"", host$password)
  } else {
    NULL
  }
}

getArgs <- function(args) {
  #edit later
  args
}




getFile <- function(local, host, fileName, direction) {
  browser()
  if(direction == 'send') file <- paste0(local, '/', fileName)
  else if(direction == 'get') file <- paste0(host$host, host$name, '/', fileName)
  else stop("Failed to construct origin's folder.")

  file
  # if(!is.null(from)) from <- from # case of send to http
  # else if(!is.null(db$from)) from <- db$from
  # else if (!is.null(db$host)) from <- paste0(db$host, db$name)
  # else stop("Failed to construct origin's folder")
  #
  # file <- paste0(from, "/", basename(fileName))
  # file
}



getTo <- function(local, host, direction) {

  if((direction == 'send') & !is.null(host$host)) paste0(host$host, host$name)
  else if((direction == 'send') & !is.null(host$to)) paste0(host$to, '/')
  else if(direction == 'get') local
  else stop("Failed to construct destination folder.")
  #
  # if (!is.null(to)) to
  # else if (!is.null(db$to)) db$to #for the rsyncL case
  # else if (!is.null(db$host)) paste0(db$host, db$name)
  # else stop("Failed to construct destination folder. 'to' or 'host' are missing.")
}


getObj <- function(host) {
  if(!is.null(host$host))  paste0(host$host, host$name)
  else if(!is.null(host$to)) host$to
  else stop("Failed to find Object to list")
}

