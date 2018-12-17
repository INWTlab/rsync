#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param local local directory
#' @param host Rsync object
#' @param fileName file to be synced (i.e .txt file, .R file, etc.)
#' @param direction the direction that it is synced in ('send'- from local to host or 'get' - from host to local)
#' @param args (character) more arguments
#'
#' @details
#' \describe{
#'   Syncs a file with of a rsync object
#' }
#'
#' @export
rsyncFile <- function(host, ...) {
  UseMethod("rsyncFile", host)
}


#' @export
rsyncFile.default <- function(local, host, fileName, direction, args) {


  pre <- getPre(host) # get password or NULL
  args = getArgs(args) # get args or NULL

  #vorher mit getFile(); doch dann Error: C stack usage too close to the limit
  #file <- getFile(local, host, fileName, direction)
  if(direction == 'send') file <- paste0(local, '/', fileName)
  else if(direction == 'get') file <- paste0(host$host, host$name, '/', fileName)
  else stop("Failed to construct origin's folder.")


  to <- getTo(local, host, direction)

  rsync::rsync(file, to, args = args, pre = pre)
}



