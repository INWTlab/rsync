#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#'
#' @details
#' \describe{
#' deletes an entry from a Rsync object
#' }
#' @export
deleteEntry <- function(host, ...) {
  UseMethod("deleteEntry", host)
}

#' @export
deleteEntry.default <- function(host, entryName, verbose = FALSE) {
  # browser()
  if (length(entryName) == 0) return(host)
  on.exit(try(file.remove(emptyDir), silent = TRUE))
  entryName <- basename(entryName)
  if(verbose == TRUE) args <-  "-rvv --delete"
  else args <- "-r --delete"
  includes <- paste(paste0("--include", " \"", entryName, "\""), collapse = " ")
  excludes <- "--exclude \"*\""
  args <- paste(args, includes, excludes)

  emptyDir <- paste0(tempdir(), "/empty/")
  dir.create(emptyDir)

  #jump directely to rsync
  pre = getPre(host)
  to = getTo(host = host, direction = 'send')
  file = emptyDir
  rsync::rsync(file, to, args = args, pre = pre)
  host
}


