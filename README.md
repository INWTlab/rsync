  
[![Travis-CI Build Status](https://travis-ci.org//INWTlab/rsync.svg?branch=master)](https://travis-ci.org/INWTlab/rsync)


## Rsync as R-Package

`rsync` is a open source file-copying tool that is freely available under the
GNU General Public License. This is an R package providing an API to rsync from
R.


## Why use rsync:

Rsync is a tool, which is used with Unix systems and allows efficient
transferring and synchronizing of files across computer systems. It is widely
used for makeing backups, copying files or mirroring.

Working with Rsync offers nice benefits, as it is:
  - fast
  - works remotly and locally 
  - minimizes data transfer, as it only transfers the changes within the files 
  - supports copying links, devices, owners, groups, and permissions

For further information about rsync, please visit https://rsync.samba.org/.

  
## Installation:

The rsync package can be downloaded and installed by running the following
command from the R console:

```
devtools::install_github("INWTlab/rsync")
```

Make sure you have the `rsync` command line tool available.


## Settings / Classes

We distinguish between three settings for which we use rsync:

- sync between local directories (`RsyncL`)
- sync with an rsync daemon and a local directory (`RsyncD`)
- sync with an rsync daemon (write only) and a local directory and reading using
  HTTP (`RsyncDHTTP`)
  
These settings are represented by S3 classes in R. The list of methods follows below.


## RsyncL Connection

### Setting up the Connection

The first step of every `rsync` process is to initialize a rsync object. For
establishing a local connection following arguements are needed:

`from`defines the name of directory path of the file to be synced, not the file
itself. `to` specifies the destination directory.

```
con <- rsync::rsyncL(
  from = "~/exampleFolder",
  to = "~/destinationFolder"
)
```

### Sending

`listEntries` takes the *rsyncL* object as input and returns the objects
contained in the destination folder (`con$to`).

```
rsync::listEntries(con)
```

Sending a file with `sendFile`.

```
rsync::sendFile(con, file = "exampleFile.R")
```

Sending a folder with `sendFolder()` syncs a complete folder between two local
directories. `pattern` defines which files from the folder shall be synced.

```
rsync::sendFolder(con, dirName, pattern = "*.Rdata")
```

`sendObject()` syncs an object with a destination folder. It will create an
'Rdata' file on-the-fly.

```
z <- 3
rsync::sendObject(con, obj = z)
```

### Deleting

`deleteEntry()` deletes an entry in the destination folder. 

```
rsync::deleteEntry(con, entryName = "z.Rdata")
```

`deleteAllEntries()` deletes all entries in the destination folder. 

```
rsync::deleteAllEntries(con)
```

### Retrieving

`getEntry()` can be used to retrieve entries.

```
rsync::getEntry(con, entryName)
```


## RsyncD/HTTP Connection 

```
conObject <- rsync::rsyncDHTTP(
  host = "rsync://user@example.de",
  name = "someFolder",
  password = "password",
  url = "https://serverAddress.de"
)
```
