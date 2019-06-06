#' API for the CLI program rsync
#'
#' Setup a rsync configuration. The configuration object can be used for access
#' to a folder.
#'
#' @param dest (character) the address to the rsync daemon or a folder.
#' @param src (character) a folder.
#' @param password (character|NULL) a password or file name in case a rsync
#'   daemon is used.
#' @param db (rsync) an object of class 'rsync' initialized with \code{rsync}.
#' @param fileName (character) a file name that exists in \code{src}
#' @param validate (logical) if the file in dest and src should be validated
#'   using a sha256 check sum.
#' @param verbose (logical) if we use 'vorbose' as option in the cli.
#' @param object (ANY) any R object you wish to store.
#' @param objectName (character) the name used to store the object. The file
#'   extension will always be a 'Rdata'.
#' @param ssh (character|NULL) argument sets the environment variable
#'   \code{RSYNC_RSH} during the call. Can be used to further specify ssh
#'   settings.
#' @param ... arguments passed to methods.
#'
#' @details
#' \code{rsync} is a command line tool. For details see
#'   \url{https://rsync.samba.org/}.
#'
#' @rdname rsync
#' @export
rsync <- function(dest, src = getwd(), password = NULL, ssh = NULL) {
  stopifnot(
    is.character(dest) && length(dest) == 1,
    is.character(src) && length(src) == 1,
    is.null(password) || is.character(password) && length(password) == 1
  )
  src <- normalizePath(src, mustWork = TRUE)
  dest <- if (grepl(":", dest))
     sub("/$", "", dest) else normalizePath(dest, mustWork = TRUE)
  ret <- list(
    dest = dest,
    src = src,
    password = password,
    ssh = ssh
  )
  class(ret) <- "rsync"
  ret
}

getPre <- function(db) {
  conType <- if (grepl("^rsync://", getDest(db))) {
    "rsync"
  } else if (grepl(":", getDest(db))) {
    "ssh"
  } else {
    "local"
  }
  if (conType == "local") {
    NULL
  } else if (conType == "rsync" & !is.null(db$password)) {
    pwd <- db$password
    pwd <- if (file.exists(pwd)) sprintf("$(cat %s)", pwd) else pwd
    sprintf("RSYNC_PASSWORD=\"%s\"", pwd)
  } else if (conType == "ssh" & !is.null(db$ssh)) {
    sprintf("RSYNC_RSH=\"%s\"", db$ssh)
  }
}

getDestFile <- function(db, fileName) {
  paste0(sub("/+$", "", db$dest), '/', fileName)
}

getSrcFile <- function(db, fileName) {
  paste0(sub("/+$", "", db$src), '/', fileName)
}

getDest <- function(db) paste0(db$dest, "/")
getSrc <- function(db) paste0(db$src, "/")

#' @export
print.rsync <- function(x, ...) {
  xchar <- paste(c("src", "dest"), c(getSrc(x), getDest(x)), sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  cat("Directory in destination:\n")
  print(listFiles(x))
  invisible(x)
}

#' @export
as.character.rsync <- function(x, ...) {
  if (!is.null(x$password)) x$password <- "****"
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}
