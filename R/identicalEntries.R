identicalEntries <- function(db, fileName, ...) {

  on.exit(try({close(srcFile); close(destFile)}, silent = TRUE))

  srcFile <- file(getSrcFile(db, fileName), open = 'rb')
  destFile <- file(getDestFile(db, fileName), open = "rb")

  if (base::identical(openssl::sha256(srcFile), openssl::sha256(destFile))) {
    message("Rsync successful: Local and host file are identical!")
    TRUE
  } else {
    warning("Src and dest file are not identical!")
    FALSE
  }
}


