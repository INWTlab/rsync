validateFile <- function(db, fileName, ...) {

  on.exit(
    try(
      {close(srcFile); close(destFile); unlink(db1$src)}, silent = TRUE))

  # We download the file a second time into a different location. Then we
  # compare if this file is identical to what we have in src. Other options
  # would be welcome.

  db1 <- db
  db1$src <- paste0(tempdir(), "/", paste0(sample(letters, 8), collapse = ""), "/")
  dir.create(db1$src)
  getFile(db1, fileName, validate = FALSE)
  srcFile <- file(getSrcFile(db, fileName), open = "rb")
  destFile <- file(getSrcFile(db1, fileName), open = "rb")

  if (base::identical(openssl::sha256(srcFile), openssl::sha256(destFile))) {
    message("Sync successful: Local and host file are identical!")
    TRUE
  } else {
    warning("Src and dest file are not identical!")
    FALSE
  }
}


