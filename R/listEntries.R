#' List entries
#'
#' List all entries in destination folder. Returns a data frame.
#'
#' @param db rsync object that contains information on the type of connection, the target directory (remote or local) and eventually a password.
#' @param ... further arguments
#'
#' @details
#' \describe{
#'   Lists entries of a Rsync object.
#' }
#'
#'
#' @export
listEntries <- function(db, ...) {
  UseMethod("listEntries", db)
}

#' @export
listEntries.default <- function(db, ...) {
  pre <- getPre(db)
  to <- getObj(db)

  dir <- rsync(NULL, to, args = NULL, pre = pre, intern = TRUE)
  dir <- dat::extract(dir, ~ !grepl("\\.$", .))
  if (length(dir) == 0) return(emptyDir())
  dir <- strsplit(dir, " +")
  dir <- do.call(rbind, dir)
  dir <- as.data.frame(dir)
  names(dir) <- c("permission", "size", "date", "time", "name")
  dir <- dat::replace(dir, "date", gsub("/", "-", dir$date))
  dir <- dat::mutar(dir, lastModified ~ as.POSIXct(paste(date, time)))
  dir <- dat::mutar(dir, size ~ as.numeric(gsub(",", "", size)))
  dat::extract(dir, c("name", "lastModified", "size"))
}

emptyDir <- function() {
  data.frame(
    name = character(0),
    lastModified = as.POSIXct(character(0)),
    size = integer(0),
    stringsAsFactors = FALSE
  )
}
