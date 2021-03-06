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
#' @param ssh (character|NULL) argument is passed as '-e' option on the command
#'   line. Can be used to further specify ssh settings.
#' @param sshProg (character|NULL) arguments sets the environment variable
#'   'RSYNC_CONNECT_PROG' during the call. Can be used to setup a ssh connection
#'   to a remote rsync daemon.
#' @param ... arguments passed to methods.
#'
#' @details
#' \code{rsync} is a command line tool. For details see
#'   \url{https://rsync.samba.org/}. From the documentation:
#'
#' \emph{There are two different ways for rsync to contact a remote system:
#'   using a remote-shell program as the transport (such as ssh or rsh) or
#'   contacting an rsync daemon directly via TCP. The remote-shell transport is
#'   used whenever the source or destination path contains a single colon (:)
#'   separator after a host specification. Contacting an rsync daemon directly
#'   happens when the source or destination path contains a double colon (::)
#'   separator after a host specification, OR when an rsync:// URL is specified
#'   (see also the "USING RSYNC-DAEMON FEATURES VIA A REMOTE-SHELL CONNECTION"
#'   section for an exception to this latter rule).}
#'
#' Currently the rsync interface in this package only allows for remote
#'   locations in the destination.
#'
#' \emph{You may also establish a daemon connection using a program as a  proxy
#' by setting the environment variable RSYNC_CONNECT_PROG to the commands
#' you wish to run in place of making a direct socket connection.} This can be
#' done using the \code{sshProg} argument.
#'
#' @examples
#' \dontrun{
#' ## Please consider examples in the Readme of this project. To get there run:
#' browseURL("https://github.com/INWTlab/rsync")
#'
#' ## Using rsync locally
#' rsync("~/someFolder")
#'
#' ## Examples for remote connections
#' rsync("rsync://user@host:port/volume", password = "~/my-pwd")
#' rsync("user@host:~/", ssh = "ssh -i./my-identity-file")
#' ### requires (netcat) on the host
#' rsync("user@host::volume", sshProg = "ssh -i./my-identity-file host nc %H 873")
#' }
#'
#' @rdname rsync
#' @export
rsync <- function(dest, src = getwd(), password = NULL, ssh = NULL, sshProg = NULL) {
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
    ssh = ssh,
    sshProg = sshProg
  )
  class(ret) <- "rsync"
  ret
}

getPre <- function(db) {
  pre <- if (!is.null(db$password)) {
    pwd <- db$password
    pwd <- if (file.exists(pwd)) sprintf("$(cat %s)", pwd) else pwd
    sprintf("RSYNC_PASSWORD=\"%s\" ", pwd)
  } else NULL
  pre <- paste0(pre, if (!is.null(db$sshProg)) {
    paste0("RSYNC_CONNECT_PROG=\"", db$sshProg, "\"")
  })
  pre
}

getArgs <- function(db) {
  ## put further command line arguments together
  if (!is.null(db$ssh)) {
    paste0("-e \"", db$ssh, "\"")
  } else {
    NULL
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
