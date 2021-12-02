#' Interface to rsync cli-tool
#'
#' Calls the CLI-program 'rsync'.
#'
#' @param file (character) source.
#' @param to (character) destination.
#' @param includes,excludes (character) with length >=1 or (NULL).
#' @param args (character) arguments passed to rsync. Default is '-rltvx' and
#'   works for most cases.
#' @param pre (character) something that is pasted in front of the 'rsync'
#'   command. E.g. a password.
#' @param intern (logical) passed to \link{system}.
#'
#' @rdname rsynccli
#' @export
rsynccli <- function(file, to, includes = NULL, excludes = NULL, args = "-rltvx", pre = NULL, intern = FALSE) {
  constructArg <- function(x, s) {
    if (is.null(x)) {
      return(x)
    }
    paste(paste0(s, " \"", x, "\""), collapse = " ")
  }

  includes <- constructArg(includes, "--include")
  excludes <- constructArg(excludes, "--exclude")
  to <- gsub(" ", "\\\\ ", to)
  file <- if (!is.null(file)) gsub(" ", "\\\\ ", file) else NULL

  command <- paste(
    pre,
    "rsync",
    args,
    includes,
    excludes,
    file,
    to
  )

  system(command, intern = intern, wait = TRUE, ignore.stdout = FALSE, ignore.stderr = FALSE)
}
