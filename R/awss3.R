#' Connection object to a AWS S3 bucket
#'
#' Only methods specific to this class are documented here. For others the
#' default method will work. This connection provides the same interface as
#' \link{rsync}.
#'
#' @param dest,src (character) an s3 bucket, e.g. \code{s3://my-bucket} or a
#'   local directory
#' @param profile (NULL|character|list) the name of a profile or a list defining
#'   a profile. In case of a list a new profile will be created which is
#'   persistent. A profile is created using \code{aws configure} and stores
#'   credentials for the user in plain text.
#' @param endpoint_url (NULL|character) The endpoint URL for S3-compatible providers like
#'   Hetzner. E.g. 'https://fsn1.your-objectstorage.com'.
#' @param force (logical) override profile if it exists.
#' @param db (awss3) connection created with \code{awss3}
#' @param fileName (character) a file name in dest/src
#' @param validate (logical) if validation should take place
#' @param verbose (logical) if TRUE print more information to the console
#' @param recursive (logical) if TRUE print full names for files in sub folders
#' @param args (character) pass additional args to aws cli. Currently only implemented for sendFile
#' @param ... arguments passed to method
#'
#' @examples
#' \dontrun{
#' awss3("s3://my-bucket", profile = list(
#'   name = "my-profile", # the name of the profile to generate
#'   aws_access_key_id = "my-access-key-id",
#'   aws_secret_access_key = "my-secret-access-key",
#'   region = "my-region"
#' ))
#' awss3("s3://my-bucket", profile = "my-profile")
#' }
#'
#' @rdname awss3
#' @export
awss3 <- function(dest, src = getwd(), profile = NULL, endpoint_url = NULL) {
  stopifnot(
    is.character(dest) && length(dest) == 1,
    is.character(src) && length(src) == 1,
    is.null(profile) ||
      (is.character(profile) && length(profile) == 1 && profileExists(profile)) ||
      (is.list(profile) && is.character(profile$name)),
    is.null(endpoint_url) || is.character(endpoint_url) && length(endpoint_url) == 1
  )
  src <- if (isS3Bucket(src)) {
    sub("/$", "", src)
  } else {
    normalizePath(src, mustWork = TRUE)
  }
  dest <- if (isS3Bucket(dest)) {
    sub("/$", "", dest)
  } else {
    normalizePath(dest, mustWork = TRUE)
  }
  if (is.list(profile)) {
    profileCreate(profile, force = TRUE)
    profile <- profile$name
  }
  ret <- list(
    dest = dest,
    src = src,
    profile = profile,
    endpoint = endpoint_url
  )
  class(ret) <- "awss3"
  ret
}

getProfile <- function(db, ...) {
  db$profile
}

isS3Bucket <- function(x) {
  grepl("^s3://", x)
}

#' @export
print.awss3 <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("AWS S3 bucket:", xchar, "\n")
  cat("Directory in destination:\n")
  print(listFiles(x))
  invisible(x)
}

#' @export
as.character.awss3 <- function(x, ...) {
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}

#' @export
#' @rdname awss3
profileCreate <- function(profile, force = FALSE) {
  name <- profile$name
  if (!force && profileExists(name)) {
    return(TRUE)
  }
  profile$name <- NULL
  for (el in names(profile)) {
    system(sprintf(
      "aws configure set %s %s --profile %s",
      el, profile[[el]], name
    ))
  }
}

profileExists <- function(profile) {
  cmd <- sprintf("aws configure list --profile %s || true", profile)
  res <- system(cmd, intern = TRUE)
  if (length(res) <= 3) FALSE else TRUE
}
