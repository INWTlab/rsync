#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#'
#' @details
#' \describe{
#' deletes an entry from a Rsync object
#' }
#' @export
deleteEntry <- function(db, ...) {
  UseMethod("deleteEntry", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
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

  #send all files from deamon to local
  sendFile(db, objects, to = emptyDir)
  list.files(emptyDir)

  #remove entryName locally:
  unlink(paste0(emptyDir,entryName))
  list.files(emptyDir)

  rsyncHelper <- rsyncDHTTP( host = db$host,
                             name = db$name,
                             password = db$password,
                             url =   "")

  #send local directory to deamon
  listEntries.default(rsyncHelper)

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

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param entryName Name of the entry to be deleted
#' @param verbose (logical) default = FALSE
#'
#' @details
#' \describe{
#'   entryName is deleted from the destination directory
#' }
#' @export
deleteEntry.RsyncL <- function(db, entryName, verbose = FALSE) {

  unlink(paste0(db$to, "/", entryName))
  db
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param entryName Name of the entry to be deleted
#' @param verbose (logical) default = FALSE
#'
#' @details
#' \describe{
#'   entryName is deleted from the Rsync object
#' }
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

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#'
#' @details
#' \describe{
#'  deletes all entries from the Rsync object
#' }
#' @export
deleteAllEntries <- function(db, ...) {
  UseMethod("deleteAllEntries", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param verbose (logical) default = FALSE
#'
#' @details
#' \describe{
#'  deletes all entries from the Rsync object
#' }
#' @export
deleteAllEntries.default <- function(db, verbose = FALSE) { #lists entries of destination folder

  dat <- listEntries(db)
  lapply(dat$name, deleteEntry, db = db, verbose = verbose)
  db
}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param verbose (logical) default = FALSE
#'
#' @details
#' \describe{
#'  deletes all entries from the destination directory
#' }
#' @export
deleteAllEntries.RsyncL <- function(db, verbose = FALSE) {
  dat <- listEntries(db)
  sapply(dat, deleteEntry, db = db, verbose = verbose)
  db
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param verbose (logical) default = FALSE
#'
#' @details
#' \describe{
#'  deletes all entries from the Rsync object
#' }
#' @export
deleteAllEntries.RsyncDHTTP <- function(db, verbose = FALSE) {
  if(db$url != "/") dat <- listEntries(db)
  else dat <- listEntries.default(db)

  lapply(dat$name, deleteEntry, db = db, verbose = verbose)
  db
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#'
#' @details
#' \describe{
#'   Sends a file to or from a Rsync object.
#' }
#' @export
sendFile <- function(db, ...) {
  UseMethod("sendFile", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object , returning: 'name', 'lastModified' and 'size'
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
sendFile.default <- function(db, file, to = "", validate = TRUE, verbose = FALSE ) {
  args <- if (verbose) "-ltvvx" else "-ltx"
  to <- to
  lapply(file, rsyncFile, db = db, args = args, to = to)

 #if (validate) rsyncSuccessful(file, paste0(db$url, "/", basename(file)))
  db
}



#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param validate (logical) default: TRUE,
#' @param verbose (logical) default: FALSE
#'
#' @details
#' \describe{
#'   Sends a local file to another local destination directory. If validate is TRUE the
#'   hash-sum of the remote file is compared to the local version. A warning is
#'   issued should the differ. The return status of the command line rsync is
#'   returned by this function.
#' }
#' @export
sendFile.RsyncL <- function(db, file, validate = TRUE, verbose = FALSE) {
  #browser()
  file <- paste0(db$from, file)
  file <- normalizePath(file, mustWork = TRUE)

  args <- if (verbose) "-ltvvx" else "-ltx"

  rsync::rsync(file, db$to, args = args)
  db
}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
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
#'
#' @details
#' \describe{
#'   Extracts a file from a Rsync object.
#' }
#' @export
extractFile <- function(db, ...) {
  UseMethod("extractFile", db)
}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param file file to be sent (i.e .txt file, .R file, etc.)
#' @param validate (logical) default: TRUE,
#' @param verbose (logical) default: FALSE
#'
#' @details
#' \describe{
#'   Extracts a file from a db and sends it to a locoal directory.
#' }
#' @export
extractFile.RsyncDHTTP <- function(db, file, to, validate = TRUE, verbose = FALSE) {
  #browser()

  pre <- sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  #args <- if (verbose) "-ltvvx" else "-ltx"
  #args <- ""
  from <-  paste0(db$host, db$name)
  file <- paste0(from, "/", basename(file))
  to <- normalizePath(to, mustWork = TRUE)

  rsync::rsync(file, to, pre = pre)
  list.files(to)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#'
#' @details
#' \describe{
#'   Extracts a file from a Rsync object.
#' }
#' @export
extractFolder <- function(db, ...) {
  UseMethod("extractFolder", db)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param file file to be sent (i.e .txt file, .R file, etc.)
#' @param validate (logical) default: TRUE,
#' @param verbose (logical) default: FALSE
#'
#' @details
#' \describe{
#'   Extracts a file from a db and sends it to a locoal directory.
#' }
#' @export
extractFolder.RsyncDHTTP <- function(db, to, folder = "", ... , validate = TRUE, verbose = FALSE) {
   if (folder != "") files <- dir(folder, full.names = TRUE, ...)
   else files <- listEntries(db)$name

  pre <- sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  from <-  paste0(db$host, db$name)
  to <- normalizePath(to, mustWork = TRUE)

  for (file in files) {file <- paste0(from, "/", basename(file))
                       rsync::rsync(file, to, pre = pre)}

  listDir(to)
}



#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param file file to be synced (i.e .txt file, .R file, etc.)
#' @param args (character) more arguments
#'
#' @details
#' \describe{
#'   Syncs a file with db
#' }
#'
#' @export
rsyncFile <- function(db, ...) {
  UseMethod("rsyncFile", db)
}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param file file to be synced (i.e .txt file, .R file, etc.)
#' @param args (character) more arguments
#'
#' @details
#' \describe{
#'   Syncs a file with db
#' }
#' @export
rsyncFile.RsyncDHTTP <- function(db, file, args) {
  pre <- sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  to <-  paste0(db$host, db$name) #db$localDir
  rsync::rsync(file, to, args = args, pre = pre)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param file file to be synced (i.e .txt file, .R file, etc.)
#' @param args (character) more arguments
#'
#' @details
#' \describe{
#'   Syncs a file between two local directories
#' }
#' @export
rsyncFile.RsyncL <- function(db, file, args) {
  pre <- sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  # pre <- paste0("RSYNC_PASSWORD=", as.character(db$password))
  to <-  paste0(db$host, db$name)
  rsync::rsync(file, to, args = args, pre = pre)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param file file to be synced (i.e .txt file, .R file, etc.)
#' @param args (character) more arguments
#'
#' @details
#' \describe{
#'   Syncs a file with db
#' }
#' @export
rsyncFile.default <- function(db, file, to, args) {
  pre <- sprintf("RSYNC_PASSWORD=\"%s\"", db$password)
  # pre <- paste0("RSYNC_PASSWORD=", as.character(db$password))
  from <-  paste0(db$host, db$name)
  file <- paste0(from, "/", basename(file))

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
 # if (grepl("rsync", localFile)) loc <- open.connection(localFile, open = "rb") #connection mit Deamon öffen funktioniert nicht
  loc <- file(localFile, open = "rb")

  if (grepl("http", remoteFile)) rem <- url(remoteFile, open = "rb")
  else rem <- file(remoteFile, open = "rb")

  if (!base::identical(openssl::sha256(loc), openssl::sha256(rem)))
    warning(sprintf("%s: Local and remote file are not the same!", localFile))
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
identicalEntries.RsyncL <- function(db, localFile, remoteFile) {
  on.exit({try(silent = TRUE, {close(loc); close(rem)})})
  loc <- file(localFile, open = "rb")
  rem <- url(remoteFile, open = "rb")
  if (!base::identical(openssl::sha256(loc), openssl::sha256(rem)))
    warning(sprintf("%s: Local and remote file are not the same!", localFile))
}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
#' @param obj R object to be sent to db
#' @param objName name of 'obj'
#' @param ... more arguments
#'
#' @details
#' \describe{
#'   Send an R object to db. This is a wrapper around \code{sendFile}.
#'   \code{...} are passed to \code{sendFile}.
#' }
#' @export
sendObject <- function(db, ...) {
  UseMethod("sendObject", db)
}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object , returning: 'name', 'lastModified' and 'size'
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
sendObject.default <- function(db, obj, to = "", objName = as.character(substitute(obj)), ...) {
  assign(objName, obj)
  save(list = objName, file = file <- paste0(tempdir(), "/", objName, ".Rdata"), compress = TRUE)
  sendFile(db, file, ...)
  db
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object , returning: 'name', 'lastModified' and 'size'
#' @param obj R object to be sent to db
#' @param objName name of 'obj'
#' @param ... more arguments
#'
#' @details
#' \describe{
#'   Send an R object to db. This is a wrapper around \code{sendFile}.
#'   \code{...} are passed to \code{sendFile}.
#' }
#' @export
sendObject.RsyncDHTTP <- function(db, obj, objName = as.character(substitute(obj)), ...) {
  assign(objName, obj)
  save(list = objName, file = file <- paste0(tempdir(), "/", objName, ".Rdata"), compress = TRUE)
  sendFile(db, file, ...)
  db
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object , returning: 'name', 'lastModified' and 'size'
#' @param obj R object to be sent to db
#' @param objName name of 'obj'
#' @param ... more arguments
#'
#' @details
#' \describe{
#'   Send an R object to local directory. This is a wrapper around \code{sendFile}.
#'   \code{...} are passed to \code{sendFile}.
#' }
#' @export
sendObject.RsyncL <- function(db, obj, objName = as.character(substitute(obj)), ...) {

  assign(objName, obj)
  save(list = objName, file = file <- paste0(tempdir(), "/", objName, ".Rdata"), compress = TRUE)
  #browser()
  fileName <- paste0(objName, ".Rdata")
  sendFile(db, fileName, ...)
  db
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object , returning: 'name', 'lastModified' and 'size'
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

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object , returning: 'name', 'lastModified' and 'size'
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
#' @export
sendFolder.default <- function(db, to, folder = "",  ..., validate = TRUE, verbose = FALSE) { #left out folder, therfore added argument "to"
  if (folder != "") files <- dir(folder, full.names = TRUE, ...)
  else {files <- listEntries(db)$name #folder not needed so far
        files <- paste0(to, "/", files) }
  to <- to
  for (file in files) sendFile(db, file, to, validate) #verbose
  db
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object , returning: 'name', 'lastModified' and 'size'
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
#' @export
sendFolder.RsyncDHTTP <- function(db, folder, ..., validate = TRUE, verbose = FALSE) {
  files <- dir(folder, full.names = TRUE, ...)
  for (file in files) sendFile(db, file, validate) #verbose
  db
}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object , returning: 'name', 'lastModified' and 'size'
#' @param folder folder, of which the content shall be sent
#' @param pattern an optional regular expression. Only file names which match the regular expression will be returned.
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
#' @export
sendFolder.RsyncL <- function(db, folder,  ..., validate = TRUE, verbose = FALSE) {

  files <- dir(folder, full.names = FALSE, ...)
  for (file in files) sendFile(db, file, validate) #verbose
  db
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
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

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
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
#' @export
getEntry.default <- function(db, entryName, file = NULL, ...) {

  ## retrun: in case of csv: data.frame; in case of rdata or json: list
  address <- paste0(db$host, db$name, "/", entryName)
  if (!is.null(file)) return(download.file(address, file))

  fileExt <- tools::file_ext(address)
  grepl <- function(p, x) base::grepl(p, x, ignore.case = TRUE)
  if (grepl("csv", fileExt)) loadcsv(db,address, ...)
  else if (grepl("rdata", fileExt)) loadrdata(db, address)
  else if (grepl("json", fileExt)) loadjson(db, address, ...)
  else stop(sprintf("cannot handle file extension: %s", fileExt))

}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
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
#' @export
getEntry.RsyncDHTTP <- function(db, entryName, file = NULL, ...) {
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

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param db Rsync object
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

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param address from where the object shall be loaded
#'
#' @details
#' \describe{
#'   loads a R data object from a local directory
#' }
#' @export
loadrdata.RsyncL <- function(db, address) {
  load(address, e <- new.env(parent = emptyenv()))
  as.list(e, all.names = TRUE)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param address from where the object shall be loaded
#'
#' @details
#' \describe{
#'   loads a R data object from a Rsync object
#' }
#' @export
loadrdata.RsyncDHTTP <- function(db, address) {
  on.exit(try(close(con), silent = TRUE))

  con <- url(address)
  load(con, e <- new.env(parent = emptyenv()))
  as.list(e, all.names = TRUE)
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param address from where the object shall be loaded
#'
#' @details
#' \describe{
#'   loads a R data object from a Rsync object
#' }
#' @export
loadrdata.default <- function(db, address) {

  on.exit(try(close(con), silent = TRUE))
  # con <- socketConnection(host = paste0(dirname(address), "/"), port = basename(address), blocking = FALSE)
  #Wie kann man eine connection zum Deamon öffnen?
  con <- file(address)
  open(con)
  as.list(con, all.names = TRUE)

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
#' @export
loadjson.default <- function(db, file, ...) {
  jsonlite::read_json(file, simplifyVector = TRUE, ...)
}



#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param x Rsync object
#' @param ... more arguments
#'
#' @details
#' \describe{
#' prints the Rsync object
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

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param x Rsync object
#' @param ... more arguments
#'
#' @details
#' \describe{
#' prints the Rsync object
#' }
#' @export
print.RsyncDHTTP <- function(x, ...) {
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
#' @param x Rsync object
#' @param ... more arguments
#'
#' @details
#' \describe{
#' prints the Rsync object
#' }
#' @export
print.RsyncD <- function(x, ...) {
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
#' @param x Rsync object
#' @param ... more arguments
#'
#' @details
#' \describe{
#' prints the local directory
#' }
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
#' @param x Rsync object
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

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param x Rsync object
#' @param ... more arguments
#'
#' @details
#' \describe{
#' converts a RsynsServer object to a character
#' }
#' @export
as.character.RsyncDHTTP <- function(x, ...) {
  x$password <- "****"
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param x Rsync object
#' @param ... more arguments
#'
#' @details
#' \describe{
#' converts a RsynsServer object to a character
#' }
#' @export
as.character.RsyncD <- function(x, ...) {
  x$password <- "****"
  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}

#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param x Rsync object
#' @param ... more arguments
#'
#' @details
#' \describe{
#' converts a RsynsServer object to a character
#' }
#' @export
as.character.RsyncL <- function(x, ...) {

  ret <- as.character.default(x)
  names(ret) <- names(x)
  ret
}


#' Rsync API
#'
#' API to use rsync as persistent file and object storage.
#'
#' @param x Rsync object
#' @param ... more arguments
#'
#' @details
#' \describe{
#' converts a RsynsServer object to a character
#' }
#' @export
listDir <- function(dirName) {
  dat <- list.files(dirName)
  dat <- as.data.frame(dat[grepl("Rdata|csv|json", dat)])
  names(dat) <- "Objects"
  dat

}


