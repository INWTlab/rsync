#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param file file to be synced (i.e .txt file, .R file, etc.)
#' @param args (character) more arguments
#'
#' @details
#' \describe{
#'   Syncs a file with db
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
  # browser()
  #browser()

  #vorher mit getFile(); doch dann Error: C stack usage too close to the limit
  #file <- getFile(local, host, fileName, direction)
  if(direction == 'send') file <- paste0(local, '/', fileName)
  else if(direction == 'get') file <- paste0(host$host, host$name, '/', fileName)
  else stop("Failed to construct origin's folder.")



  to <- getTo(local, host, direction)

  rsync::rsync(file, to, args = args, pre = pre)
}



