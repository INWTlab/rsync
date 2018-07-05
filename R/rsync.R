#' Interface to rsync cli-tool
#'
#' Calls the CLI-program 'rsync'.
#'
#' @param from (character) source
#' @param to   (character) target
#' @param includes,excludes (chracter) with length >=1 restictions
#' @param args (character) more arguments
#' @param pre (character) something which is pasted before the 'rsync' command
#' @param ... arguments passed to rsync
#'
#' @rdname rsync
#' @export
rsync <- function(from, to, includes = NULL, excludes = NULL, args = "-rltvx", pre = NULL) {

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
    from,
    to
  )

  system(command, intern = FALSE, wait = TRUE, ignore.stdout = FALSE, ignore.stderr = FALSE)

}

