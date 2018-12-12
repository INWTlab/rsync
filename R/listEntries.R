#' List entries
#'
#' List all entries in destination folder. Returns a data frame.
#'
#' @param db rsync object connection
#' @param ... ignored
#'
#' @export
listEntries <- function(host, ...) {
  UseMethod("listEntries", host)
}

#' @export
listEntries.default <- function(host, ...) {
  pre <- getPre(host)

  to <- getObj(host)


  dir <- rsync(NULL, to, args = NULL, pre = pre, intern = TRUE) #send NULL to destination folder and view it
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
