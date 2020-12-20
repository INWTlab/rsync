#' @rdname rsync
#' @export
listFiles <- function(db, ...) {
  UseMethod("listFiles", db)
}

#' @import data.table
#' @rdname rsync
#' @export
listFiles.default <- function(db, ...) {
  pre <- getPre(db)
  to <- getDest(db)
  args <- getArgs(db)

  dir <- rsynccli(NULL, to, args = args, pre = pre, intern = TRUE)
  dir <- dat::extract(dir, ~ !grepl("\\.$", .))
  if (length(dir) == 0) return(emptyDir())

  dir <- strsplit(dir, " +")
  dir <- do.call(rbind, dir)
  dir <- as.data.frame(dir)
  names(dir) <- c("permission", "size", "date", "time", "name")
  dir <- dat::replace(dir, "date", gsub("/", "-", dir$date))
  dir <- dat::mutar(dir, lastModified ~ as.POSIXct(paste(date, time)))
  dir <- dat::mutar(dir, size ~ as.numeric(gsub(",", "", size)))
  dir <- dat::mutar(dir, name ~ as.character(name))
  dir <- dat::extract(dir, c("name", "lastModified", "size"))
  dir
}

emptyDir <- function() {
  data.frame(
    name = character(0),
    lastModified = as.POSIXct(character(0)),
    size = integer(0),
    stringsAsFactors = FALSE
  )
}

#' @rdname awss3
#' @export
listFiles.awss3 <- function(db, ...) {
  dest <- getDest(db)
  profile <- getProfile(db)
  if (!isS3Bucket(dest)) return(NextMethod())
  dir <- awscli(NULL, dest, args = "ls", profile = profile, intern = TRUE)
  dir <- dat::extract(dir, ~ !grepl("\\.$", .))
  if (length(dir) == 0) return(emptyDir())
  dir <- strsplit(dir, " +")
  dir <- do.call(rbind, dir)
  dir <- as.data.frame(dir)
  names(dir) <- c("date", "time", "size", "name")
  dir <- dat::replace(dir, "date", gsub("/", "-", dir$date))
  dir <- dat::mutar(dir, lastModified ~ as.POSIXct(paste(date, time)))
  dir <- dat::mutar(dir, size ~ as.numeric(gsub(",", "", size)))
  dir <- dat::mutar(dir, name ~ as.character(name))
  dir <- dat::extract(dir, c("name", "lastModified", "size"))
  dir
}

