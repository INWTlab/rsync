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

  status <- system(command, intern = intern, wait = TRUE, ignore.stdout = FALSE, ignore.stderr = FALSE)
  checkSystemResult(status)
}


#' Check System Command Result for Exit Code
#'
#' Evaluates the result from R's \code{system()} function and checks for a
#' non-zero exit status. If the system command failed (i.e., returned a non-zero
#' exit status), the function throws an error. If the result contains the
#' command's output, it is returned.
#'
#' @param result The result of a \code{system()} function execution. This can be:
#'   \itemize{
#'     \item A character vector containing the command's output.
#'     \item A numeric value representing the exit status code.
#'     \item An object with a \code{status} attribute.
#'   }
#' @return
#'   \itemize{
#'     \item If \code{result} is a character vector (command output) and has no
#'       \code{status} attribute, returns the output.
#'     \item If \code{result} is numeric (exit status code), returns the status
#'       code.
#'     \item If the command failed (non-zero exit status), the function stops
#'       with an error message.
#'   }
#' @export
checkSystemResult <- function(result) {
  if (is.character(result) && is.null(attr(result, "status"))) {
    sys_output <- result
    return(sys_output)
  }

  if (is.numeric(result)) {
    status <- result
  } else {
    status <- if (!is.null(attr(result, "status"))) attr(result, "status") else 0
  }

  if (status != 0) stop("Command failed with status: ", status)

  return(status)
}
