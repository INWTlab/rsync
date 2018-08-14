
#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param type (character) the type of connection. Possible are RsyncDHTTP (default), RsyncD, RsyncL.
#' @param host (character) the url, where the host file is stored
#' @param name (character) the name of the target server
#' @param password (character) the password to the corresponding target server
#' @param url (character) the url to the corresponding target server
#'
#' @details
#' \describe{
#'  Connection for a RsyncServer. All arguments are characters.
#' }
#'
#' @export
connection <-function(host = "", name = "", password = "", url = "", type = "RsyncDHTTP", from = "", to = "") {
  # validate input here
  if(type != "RsyncL"){
  host <- paste0(sub("/$", "", host), "/")
  name <- sub("^/", "", name)
  url <- paste0(sub("/$", "", url), "/")}


  if(type == "RsyncD") aoos::retList("RsyncD")
  else if(type == "RsyncDHTTP") aoos::retList(c("RsyncDHTTP", "RsyncD"))
  else if(type == "RsyncL") aoos::retList(c("RsyncL", "RsyncD"))
  else warning("unknown connection type")
}


#' @export
listEntries <- function(db, ...) {
  UseMethod("listEntries", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db RsyncServer object , returning: 'name', 'lastModified' and 'size'
#'
#' @details
#' \describe{
#' Returns a data.frame with the elements in the rsync storage.
#' }
#'
#' @export
listEntries.RsyncDHTTP <- function(db) {
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


#' @export
listEntries.RsyncL <- function(db) {

  # print("files of in to:")
  # list.files(db$to)
  dat <- as.data.frame(list.files(db$to))
  names(dat) <- "Objects"
  dat
}



#' @export
listEntries.default <- function(db) {


  pre <- sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  to <-  paste0(db$host, db$name)

  # print("files of rsync deamon:")
  command <- paste(
    pre,
    "rsync",
    to
  )
  dat <- system(command, intern = TRUE, wait = TRUE, ignore.stdout = FALSE, ignore.stderr = FALSE)
  # browser()

  dat <- as.data.frame(dat)

  dat <- dat[2:4,1] #first line is dropped
  dat <- as.data.frame(dat)
  dat <- dat %>% separate(dat, into = c("shortcut", "size","date", "time", "name"), sep = "\\s+")
  #####


  dat <- na.omit(dat)
  dat
  }


#' @export
deleteEntry <- function(db, ...) {
  UseMethod("deleteEntry", db)
}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db RsyncServer object , returning: 'name', 'lastModified' and 'size'
#' @param entryName Name of the entry to be deleted
#' @param verbose (logical) default = FALSE
#'
#' @details
#' \describe{
#'   The entryName is specified as returned by ls.
#' }
#'
#' @export
deleteEntry.default <- function(db, entryName, verbose = FALSE) {
  # browser()
  if (length(entryName) == 0) return(db)
  on.exit(try(file.remove(emptyDir), silent = TRUE))
  entryName <- basename(entryName)
  args <- if (verbose) "-rvv --delete" else "-r --delete"
  includes <- paste(paste0("--include", " \"", entryName, "\""), collapse = " ")
  excludes <- "--exclude \"*\""
  args <- paste(args, includes, excludes)
  emptyDir <- paste0(tempdir(), "/empty/")
  dir.create(emptyDir)


  objects <- listEntries(db)$name

  #send all files vom deamon to local -> sendFile of RsynsD object
  sendFile(db, objects, to = emptyDir) #works with one file
  list.files(emptyDir) #worked

  #remove entryName locally:
  unlink(paste0(emptyDir,entryName)) #worked
  list.files(emptyDir) #worked


  rsyncHelper <- connection( type = "RsyncDHTTP",
                             host = db$host,
                             name = db$name,
                             password = db$password,
                             url =   "")




  # #send local directory to deamon
  listEntries.default(rsyncHelper)

  #insted of calling rsync()

  pre <- sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  to <-  paste0(db$host, db$name)
  from <- emptyDir

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

   dat  <- as.data.frame(listEntries(db))
   dat <- na.omit(dat)
   dat

}


#' @export
deleteEntry.RsyncL <- function(db, entryName, verbose = FALSE) {

  unlink(paste0(db$to, "/", entryName))
  db
}

#' @export
deleteEntry.RsyncDHTTP <- function(db, entryName, verbose = FALSE) {
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


#' @export
deleteAllEntries <- function(db, ...) {
  UseMethod("deleteAllEntries", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db RsyncServer object , returning: 'name', 'lastModified' and 'size'
#' @param verbose (logical) default = FALSE
#'
#'
#' @details
#' \describe{
#'   ...
#' }
#'
#' @export
deleteAllEntries.default <- function(db, verbose = FALSE) { #lists entries of destination folder

  dat <- listEntries(db)
  lapply(dat$name, deleteEntry, db = db, verbose = verbose)
  db
}

#' @export
deleteAllEntries.RsyncL <- function(db, verbose = FALSE) {
  dat <- listEntries(db)
  sapply(dat, deleteEntry, db = db, verbose = verbose)
  db
}


#' @export
deleteAllEntries.RsyncDHTTP <- function(db, verbose = FALSE) {
  if(db$url != "/") dat <- listEntries(db)
  else dat <- listEntries.default(db)

  lapply(dat$name, deleteEntry, db = db, verbose = verbose)
  db
}


#' @export
sendFile <- function(db, ...) {
  UseMethod("sendFile", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db RsyncServer object , returning: 'name', 'lastModified' and 'size'
#' @param file file to be sent (i.e .txt file, .R file, etc.)
#' @param validate (logical) default: TRUE,
#' @param verbose (logical) default: FALSE
#'
#' @details
#' \describe{
#'   Sends a file (file in local file system) to db. If validate is TRUE the
#'   hash-sum of the remote file is compared to the local version. A warning is
#'   issued should the differ. The return status of the command line rsync is
#'   returned by this function.
#' }
#'
#' @export
sendFile.default <- function(db, file, validate = TRUE, verbose = FALSE, to = "") {

  args <- if (verbose) "-ltvvx" else "-ltx"
  lapply(file, rsyncFile, db = db, args = args, to = to)

 #if (validate) rsyncSuccessful(file, paste0(db$url, "/", basename(file)))
  db
}




#' @export
sendFile.RsyncL <- function(db, file = "", validate = TRUE, verbose = FALSE) {
  if (file != "") file <- normalizePath(file, mustWork = TRUE)
  else  file <- normalizePath(db$from, mustWork = TRUE)
  args <- if (verbose) "-ltvvx" else "-ltx"

  rsync::rsync(file, db$to, args = args)
  db
}

#' @export
sendFile.RsyncDHTTP <- function(db, file, validate = TRUE, verbose = FALSE) {
  file <- normalizePath(file, mustWork = TRUE)
  args <- if (verbose) "-ltvvx" else "-ltx"
  lapply(file, rsyncFile, db = db, args = args)
  # if (validate) rsyncSuccessful(file, paste0(db$url, "/", basename(file)))
  db
}





#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db RsyncServer object , returning: 'name', 'lastModified' and 'size'
#' @param file file to be synced (i.e .txt file, .R file, etc.)
#' @param args (character) more arguments
#'
#' @details
#' \describe{
#'   Syncs a file to a db
#' }
#'
#' @export
rsyncFile <- function(db, ...) {
  UseMethod("rsyncFile", db)
}



#' @export
rsyncFile.RsyncDHTTP <- function(db, file, args) {
  pre <- sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  to <-  paste0(db$host, db$name) #db$localDir
  rsync::rsync(file, to, args = args, pre = pre)
}


#' @export
rsyncFile.RsyncL <- function(db, file, args) {
  pre <- sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  # pre <- paste0("RSYNC_PASSWORD=", as.character(db$password))
  to <-  paste0(db$host, db$name)
  rsync::rsync(file, to, args = args, pre = pre)
}

#' @export
rsyncFile.default <- function(db, file, to, args) {
  pre <- sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  # pre <- paste0("RSYNC_PASSWORD=", as.character(db$password))
  from <-  paste0(db$host, db$name)
  file <- paste0(from, "/", file)

  rsync::rsync(file, to, args = args, pre = pre)
}





#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param localFile source file
#' @param remoteFile target file
#'
#' @details
#' \describe{
#'   Tests if the sync process was successfull. It returns TRUE in this case, FALSE in every other case.
#' }
#'
#' @export
rsyncSuccessful <- function(localFile, remoteFile) {
  mapply(identicalEntries, localFile = localFile, remoteFile = remoteFile)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param localFile source file
#' @param remoteFile target file
#'
#' @details
#' \describe{
#' Tests if two files are exactly identical. It returns TRUE in this case, FALSE in every other case.
#' }
#'
#' @export
identicalEntries <- function(localFile, remoteFile) {
  on.exit({try(silent = TRUE, {close(loc); close(rem)})})
  loc <- file(localFile, open = "rb")
  rem <- url(remoteFile, open = "rb")
  if (!base::identical(openssl::sha256(loc), openssl::sha256(rem)))
    warning(sprintf("%s: Local and remote file are not the same!", localFile))
}


#' @export
sendObject <- function(db, ...) {
  UseMethod("sendObject", db)
}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db RsyncServer object , returning: 'name', 'lastModified' and 'size'
#' @param obj R object to be sent to db
#' @param objName name of 'obj'
#' @param ... more arguments
#'
#' @details
#' \describe{
#'   Send an R object to db. This is a wrapper around \code{sendFile}.
#'   \code{...} are passed to \code{sendFile}.
#' }
#'
#' @export
sendObject.default <- function(db, obj, objName = as.character(substitute(obj)), ...) {
  assign(objName, obj)
  save(list = objName, file = file <- paste0(tempdir(), "/", objName, ".Rdata"), compress = TRUE)
  sendFile(db, file, ...)
  db
}







#' @export
sendObject.RsyncDHTTP <- function(db, obj, objName = as.character(substitute(obj)), ...) {
  assign(objName, obj)
  save(list = objName, file = file <- paste0(tempdir(), "/", objName, ".Rdata"), compress = TRUE)
  sendFile(db, file, ...)
  db
}


#' @export
sendObject.RsyncL <- function(db, obj, objName = as.character(substitute(obj)), ...) {
  assign(objName, obj)
  save(list = objName, file = file <- paste0(tempdir(), "/", objName, ".Rdata"), compress = TRUE)
  db$from <- file
  sendFile(db, ...)
  db
}
#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db RsyncServer object , returning: 'name', 'lastModified' and 'size'
#' @param folder folder, of which the content shall be sent
#' @param ... more arguments
#' @param validate (logical) default = TRUE
#' @param verbose (logical) default = TRUE
#'
#'
#' @details
#' \describe{
#'   Sends the content of a folder to db using \code{sendFile}. \code{...} are
#'   passed to \link{dir}. \code{validate} and \code{verbose} are as in
#'   \code{sendFile}.
#' }
#'
#' @export
sendFolder <- function(db, ...) {
  UseMethod("sendFolder", db)
}


#' @export
sendFolder.default <- function(db, folder, ..., validate = TRUE, verbose = FALSE) {
  files <- dir(folder, full.names = TRUE, ...)
  for (file in files) sendFile(db, file, validate) #verbose
  db
}

#' @export
sendFolder.RsyncL <- function(db, folder, ..., validate = TRUE, verbose = FALSE) {

  files <- dir(folder, full.names = TRUE, ...)
  for (file in files) sendFile(db, file, validate) #verbose
  db
}
#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db RsyncServer object , returning: 'name', 'lastModified' and 'size'
#' @param entryName Name of the entry in db
#' @param file (character)  default= NULL
#' @param ... more arguments
#'
#' @details
#' \describe{
#'   If \code{file} is a character the entry is saved there first. Then it is
#'   tried to load that file into R and return it from this function. This is
#'   implemented for csv, json and Rdata files. \code{...} are passed to
#'   \link{download.file} which is only used in case \code{file} is not
#'   \code{NULL}.
#' }
#'
#' @export
getEntry <- function(db, ...) {
  UseMethod("getEntry", db)
}



#' @export
getEntry.default <- function(db, entryName, file = NULL, ...) {
  ## retrun: in case of csv: data.frame; in case of rdata or json: list
  address <- paste0(db$url, entryName)
  if (!is.null(file)) return(download.file(address, file))

  fileExt <- tools::file_ext(address)
  grepl <- function(p, x) base::grepl(p, x, ignore.case = TRUE)
  if (grepl("csv", fileExt)) loadcsv(db,address, ...)
  else if (grepl("rdata", fileExt)) loadrdata(db, address)
  else if (grepl("json", fileExt)) loadjson(db, address, ...)
  else stop(sprintf("cannot handle file extension: %s", fileExt))

}

#redundant?
#' @export
getEntry.RsyncL <- function(db, entryName, file = NULL, ...) {
  ## retrun: in case of csv: data.frame; in case of rdata or json: list
  address <- paste0(db$to, entryName)

  fileExt <- tools::file_ext(address)
  grepl <- function(p, x) base::grepl(p, x, ignore.case = TRUE)
  if (grepl("csv", fileExt)) loadcsv(db, address, ...)
  else if (grepl("rdata", fileExt)) loadrdata(db, address)
  else if (grepl("json", fileExt)) loadjson(db, address, ...)
  else stop(sprintf("cannot handle file extension: %s", fileExt))

}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param address from where the object shall be loaded
#'
#' @details
#' \describe{
#'   loads a R data object
#' }
#'
#' @export
loadrdata <- function(db, ...) {
  UseMethod("loadrdata", db)
}


#' @export
loadrdata.RsyncL <- function(db, address) {
  load(address, e <- new.env(parent = emptyenv()))
  as.list(e, all.names = TRUE)
}

#' @export
loadrdata.default <- function(db, address) {
  on.exit(try(close(con), silent = TRUE))
  con <- url(address)
  load(con, e <- new.env(parent = emptyenv()))
  as.list(e, all.names = TRUE)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param file file of type .csv
#' @param ... more arguments
#'
#' @details
#' \describe{
#' loads a csv file
#' }
#'
#' @export
loadcsv <- function(db, ...) {
  UseMethod("loadcsv", db)
}


#'     @export
loadcsv.default <- function(db, file, ...) {
  data.table::fread(file, ..., showProgress = FALSE, data.table = FALSE)
}




#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param file file of type json
#' @param ... more arguments
#'
#' @details
#' \describe{
#' loads a json file
#' }
#'
#'#' @export
loadjson <- function(db, ...) {
  UseMethod("loadjson", db)
}

#' @export
loadjson.default <- function(db, file, ...) {
  jsonlite::read_json(file, simplifyVector = TRUE, ...)
}



#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param x RsyncServer object
#' @param ... more arguments
#'
#' @details
#' \describe{
#' prints the RsyncServer object
#' }
#'
#' @export
print.RsyncServer <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  print(listEntries(x), ...)
}


#' @export
print.RsyncDHTTP <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  print(listEntries(x), ...)
}

#' @export
print.RsyncD <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  print(listEntries(x), ...)
}

#' @export
print.RsyncL <- function(x, ...) {
  xchar <- as.character(x)
  xchar <- paste(names(xchar), xchar, sep = ": ")
  xchar <- paste0("\n  ", xchar)
  xchar <- paste(xchar, collapse = "")
  cat("Rsync server:", xchar, "\n")
  print(listEntries(x), ...)
}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param x RsyncServer object
#' @param ... more arguments
#'
#' @details
#' \describe{
#' converts a RsynsServer object to a character
#' }
#'
#' @export
as.character.RsyncServer <- function(x, ...) {
  x$password <- "****"
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}


#' @export
as.character.RsyncDHTTP <- function(x, ...) {
  x$password <- "****"
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}


#' @export
as.character.RsyncD <- function(x, ...) {
  x$password <- "****"
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}

#' @export
as.character.RsyncL <- function(x, ...) {

  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}

