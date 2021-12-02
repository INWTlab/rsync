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
  if (length(dir) == 0) {
    return(emptyDir())
  }

  dir <- as.data.frame(do.call(rbind, strsplit_spaces_first_n(dir, n = 5)))
  names(dir) <- c("permission", "size", "date", "time", "name")
  dir <- dat::replace(dir, "date", gsub("/", "-", dir$date))
  dir <- dat::mutar(dir, lastModified ~ as.POSIXct(paste(date, time)))
  dir <- dat::mutar(dir, size ~ as.numeric(gsub(",", "", size)))
  dir <- dat::mutar(dir, name ~ as.character(name))
  dir <- dat::extract(dir, c("name", "lastModified", "size"))
  dir
}

## split on whitespaces, but only using at most the first (n - 1) splits (to give at most n output columns)
strsplit_spaces_first_n <- function(txt, n) {
    lapply(txt, function(z) {
        ## how many splits could we have on this text?
        nsplits <- length(gregexpr("[[:space:]]+", z)[[1]])
        ## split at most that many times
        rgxp <- paste(c(rep("([^[:space:]]+)", min(nsplits, n - 1)), "(.*)"), collapse = "[[:space:]]+")
        regmatches(z, regexec(rgxp, z))[[1]][-1]
    })
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
listFiles.awss3 <- function(db, recursive = FALSE, ...) {
  dest <- getDest(db)
  profile <- getProfile(db)
  if (!isS3Bucket(dest)) {
    return(NextMethod())
  }
  args <- if (recursive) "ls --recursive" else "ls"
  dir <- awscli(NULL, dest, args = args, profile = profile, intern = TRUE)
  dir <- dat::extract(dir, ~ !grepl("\\.$", .))
  if (length(dir) == 0) {
    return(emptyDir())
  }
  dir <- strsplit(dir, " +")
  dir <- lapply(dir, collapseFileNamesWithSpaces)

  dir <- lapply(dir, addMissingCol)
  dir <- do.call(rbind, dir)
  dir <- as.data.frame(dir)
  names(dir) <- c("date", "time", "size", "name")
  dir <- dat::replace(dir, "date", gsub("/", "-", dir$date))
  dir <- dat::mutar(dir, lastModified ~ toPOSIX(paste(date, time)))
  dir <- dat::mutar(dir, size ~ suppressWarnings(as.numeric(gsub(",", "", size))))
  dir <- dat::mutar(dir, name ~ as.character(name))
  dir <- dat::extract(dir, c("name", "lastModified", "size"))
  dir
}

addMissingCol <- function(x) {
  if (length(x) == 3) {
    c("", x)
  } # add an empty time
  else {
    x
  }
}

collapseFileNamesWithSpaces <- function(x) {
  if (any(x == "PRE")) {
    posOfName <- 3
  } else {
    posOfName <- 4
  }
  c(x[1:(posOfName - 1)], paste(sub("/$", "", x[posOfName:length(x)]), collapse = " "))
}

toPOSIX <- function(x) {
  # whitespaces are NAs
  as.POSIXct(ifelse(grepl("\\S", x), x, NA))
}
