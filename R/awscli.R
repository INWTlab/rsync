awscli <- function(src, dest, includes = NULL, excludes = NULL, args = "", profile = NULL, intern = FALSE) {
  constructArg <- function(x, s) {
    if (is.null(x)) {
      return(x)
    }
    paste(paste0(s, " \"", x, "\""), collapse = " ")
  }

  includes <- constructArg(includes, "--include")
  excludes <- constructArg(excludes, "--exclude")
  profile <- if (is.null(profile)) "" else paste("--profile", profile)

  command <- paste(
    "aws s3",
    args,
    excludes,
    includes,
    profile,
    src,
    dest
  )
  ## cat(command, "\n")

  system(command, intern = intern, wait = TRUE, ignore.stdout = FALSE, ignore.stderr = FALSE)
}
