#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @inheritParams sendFile
#'
#' @details
#' \describe{
#'   Sends an object (from the environment) to a rsync target. If validate is
#'       TRUE the hash-sum of the remote file is compared to the local version.
#'       A warning is issued should they differ.
#' }
#' @export
sendObject <- function(db, ...) {
  UseMethod("sendObject", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#' @inheritParams sendFile
#' @param object object in the environment, which shall be sent to a target
#'     directory
#' @param objectName the object's name that is constructed from `object`
#' @param validate TRUE. validates if entryName is identical in both locations.
#' @param verbose FALSE. If set to TRUE, it prints details of the process.
#' @export
sendObject.default <- function(db, object, objectName = as.character(substitute(object)), validate = FALSE, verbose = FALSE, ...) {

  args <- if (verbose) "-ltvvx" else "-ltx"
  assign(objectName, object)
  fileName <- paste0(objectName, ".Rdata")
  save(
    list = objectName,
    file =  file <- getSrcFile(db, fileName),
    compress = TRUE
  )
  sendFile(db, fileName, validate = validate, verbose = verbose, ...)

}
