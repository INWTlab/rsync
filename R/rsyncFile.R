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

  file <- getFile(local, host, fileName, direction)
  to <- getTo(local, host, direction)

  rsync::rsync(file, to, args = args, pre = pre)
}



