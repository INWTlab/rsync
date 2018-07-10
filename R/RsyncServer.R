#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' \describe{
#' \item{const(host, name, password, url)}{
#'   Constructor for a RsyncServer. All arguments are character.
#' }
#' \item{ls(db)}{
#'   Returns a data.frame with the elements in the rsync storage.
#' }
#' \item{delete(db, entryName)}{
#'   The entryName is specified as returned by ls.
#' }
#' \item{deleteAllEntries(db)}{
#'   ...
#' }
#' \item{sendFile(db, file, validate = TRUE, verbose = TRUE)}{
#'   Sends a file (file in local file system) to db. If validate is TRUE the
#'   hash-sum of the remote file is compared to the local version. A warning is
#'   issued should the differ. The return status of the command line rsync is
#'   returned by this function.
#' }
#' \item{sendFolder(db, folder, ..., validate = TRUE, verbose = TRUE)}{
#'   Sends the content of a folder to db using \code{sendFile}. \code{...} are
#'   passed to \link{dir}. \code{validate} and \code{verbose} are as in
#'   \code{sendFile}.
#' }
#' \item{sendObject(db, obj, ...)}{
#'   Send an R object to db. This is a wrapper around \code{sendFile}.
#'   \code{...} are passed to \code{sendFile}.
#' }
#' \item{get(db, entryName, file = NULL, ..., loader)}{
#'   If \code{file} is a character the entry is saved there first. Then it is
#'   tried to load that file into R and return it from this function. This is
#'   implemented for csv, json and Rdata files. \code{...} are passed to
#'   \link{download.file} which is only used in case \code{file} is not
#'   \code{NULL}.
#' }
#' }
#'
#' @export


  const <- function(host, name, password, url) {
    # validate input here
    host <- paste0(sub("/$", "", host), "/")
    name <- sub("^/", "", name)
    url <- paste0(sub("/$", "", url), "/")
    aoos::retList("RsyncServer")
  }

  ls <- function(db) {
    ## db (RsyncServer)
    ## return data.frame(name, lastModified, size)
    dat <- xml2::read_html(db$url)
    dat <- rvest::html_table(dat)
    dat <- as.data.frame(dat)
    dat <- dat[, c("Name", "Last.modified", "Size")]
    names(dat) <- c("name", "lastModified", "size")
    dat <- dat[dat$name != "Parent Directory", ]
    dat <- dat[dat$name != "", ]
    dat <- dat[order(dat$lastModified, decreasing = TRUE), ]
    row.names(dat) <- NULL
    dat$lastModified <- as.POSIXct(dat$lastModified)
    tibble::as.tibble(dat)
  }

  delete <- function(db, entryName, verbose = FALSE) {
    if (length(entryName) == 0) return(db)
    on.exit(try(file.remove(emptyDir), silent = TRUE))
    entryName <- basename(entryName)
    args <- if (verbose) "-rvv --delete" else "-r --delete"
    includes <- paste(paste0("--include", " \"", entryName, "\""), collapse = " ")
    excludes <- "--exclude \"*\""
    args <- paste(args, includes, excludes)
    emptyDir <- paste0(tempdir(), "/empty/")
    dir.create(emptyDir)
    rsyncFile(db, emptyDir, args = args)
    db
  }

  deleteAllEntries <- function(db, verbose = FALSE) {
    dat <- ls(db)
    lapply(dat$name, delete, db = db, verbose = verbose)
    db
  }

  sendFile <- function(db, file, validate = TRUE, verbose = FALSE) {
    file <- normalizePath(file, mustWork = TRUE)
    args <- if (verbose) "-ltvvx" else "-ltx"
    lapply(file, rsyncFile, db = db, args = args)
    if (validate) rsyncSuccessful(file, paste0(db$url, "/", basename(file)))
    db
  }

  rsyncFile <- function(db, file, args) {
    pre <- sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
    to <- paste0(db$host, db$name)
    rsync::rsync(file, to, args = args, pre = pre)
  }

  rsyncSuccessful <- function(localFile, remoteFile) {
    mapply(identical, localFile = localFile, remoteFile = remoteFile)
  }

  identical <- function(localFile, remoteFile) {
    on.exit({try(silent = TRUE, {close(loc); close(rem)})})
    loc <- file(localFile, open = "rb")
    rem <- url(remoteFile, open = "rb")
    if (!base::identical(openssl::sha256(loc), openssl::sha256(rem)))
      warning(sprintf("%s: Local and remote file are not the same!", localFile))
  }

  sendObject <- function(db, obj, objName = as.character(substitute(obj)), ...) {
    assign(objName, obj)
    save(list = objName, file = file <- paste0(tempdir(), "/", objName, ".Rdata"), compress = TRUE)
    sendFile(db, file, ...)
    db
  }

  sendFolder <- function(db, folder, ..., validate = TRUE, verbose = FALSE) {
    files <- dir(folder, full.names = TRUE, ...)
    for (file in files) sendFile(db, file, validate, verbose)
    db
  }

  get <- function(db, entryName, file = NULL, ...) {
    ## retrun: in case of csv: data.frame; in case of rdata or json: list
    address <- paste0(db$url, entryName)
    if (!is.null(file)) return(download.file(address, file))

    fileExt <- tools::file_ext(address)
    grepl <- function(p, x) base::grepl(p, x, ignore.case = TRUE)
    if (grepl("csv", fileExt)) loadcsv(address, ...)
    else if (grepl("rdata", fileExt)) loadrdata(address)
    else if (grepl("json", fileExt)) loadjson(address, ...)
    else stop(sprintf("cannot handle file extension: %s", fileExt))

  }

  loadrdata <- function(address) {
    on.exit(try(close(con), silent = TRUE))
    con <- url(address)
    load(con, e <- new.env(parent = emptyenv()))
    as.list(e, all.names = TRUE)
  }

  loadcsv <- function(file, ...) {
    data.table::fread(file, ..., showProgress = FALSE, data.table = FALSE)
  }

  loadjson <- function(file, ...) {
    jsonlite::read_json(file, simplifyVector = TRUE, ...)
  }



#' @export
print.RsyncServer <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  print(RsyncServer$ls(x), ...)
}

#' @export
as.character.RsyncServer <- function(x, ...) {
  x$password <- "****"
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}

