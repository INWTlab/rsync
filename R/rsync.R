#' Interface to rsync cli-tool
#'
#' Calls the CLI-program 'rsync'.
#'
#' @param file (character) source
#' @param to (character) target
#' @param includes,excludes (character) with length >=1
#' @param args (character) arguments passed to rsync. Default is '-rltvx' and
#'   works for most cases.
#' @param pre (character) something which is pasted before the 'rsync' command.
#'   E.g. a password
#' @param intern (logical) passed to \link{system}
#'
#' @rdname rsync
#' @export
rsync <- function(file, to, includes = NULL, excludes = NULL, args = "-rltvx", pre = NULL, intern = FALSE) {

  constructArg <- function(x, s) {
    if (is.null(x)) return(x)
    paste(paste0(s, " \"", x, "\""), collapse = " ")
  }

  if (grepl("Windows", Sys.getenv("OS"))) {
    cat("Sorry, this function can only be used in a linux environment!\n")
    return(FALSE)
  }

  includes <- constructArg(includes, "--include")
  excludes <- constructArg(excludes, "--exclude")

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

