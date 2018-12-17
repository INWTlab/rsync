#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param localFile source file
#' @param remoteFile target file
#'
#' @details
#' \describe{
#' Tests if two files are exactly identical. It returns TRUE in this case, FALSE in every other case.
#' }
#'
#'
#' @export
identicalEntries <- function(host, ...) {
  UseMethod("identicalEntries", host)
}


#' @export
identicalEntries.default <- function(local, host, entryName) {

  on.exit({try(silent = TRUE, {close(locFile); close(hostFile)})})
 # if (grepl("rsync", localFile)) loc <- open.connection(localFile, open = "rb") #connection mit Deamon ?ffen funktioniert nicht
  locFile <- file(local, open = "rb")
# browser()
  if(!is.null(host$url)) {
    hostFile <- url(host$url, open = "rb") # for rsyncDHTTP case
  } else if ((is.null(host$url) & grepl("rsync", host$host))) { #case of rsyncD
    # hostfile <- file(paste0(host$host, host$name), open = "rb") #how to open connection to rsyncD?
  } else { #rsyncL
      hostFile <- file(host, open = "rb")
  }
   #browser()

  if (base::identical(openssl::sha256(locFile), openssl::sha256(hostFile))) {
    print("Local and host file are identical!")
  } else {
    warning("Local and host file are not identical!")
  }
}


