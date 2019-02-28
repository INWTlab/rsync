[![Travis-CI Build Status](https://travis-ci.org//INWTlab/rsync.svg?branch=master)](https://travis-ci.org/INWTlab/rsync)

## Rsync as R-Package

`rsync` is a open source file-copying tool that is freely available under the
GNU General Public License. This is a R package providing an API to rsync from
R.


## Why use rsync:

Rsync is a tool, which is used with Unix systems and allows efficient
transferring and synchronizing of files across systems. It is widely
used for making backups, copying files or mirroring them.

Working with Rsync offers nice benefits, as it is:
  - fast
  - works remotly and locally 
  - minimizes data transfer, as it only transfers the changes within the files 
  - supports copying links, devices, owners, groups, and permissions

For further information about rsync, please visit https://rsync.samba.org/.

  
## Installation:

The rsync R package can be downloaded and installed by running the following
command from the R console:

```
devtools::install_github("INWTlab/rsync")
```

Make sure you have the `rsync` command line tool available.

## Settings / Classes

We distinguish between different settings for which we use rsync:

- sync between local directories: *RsyncL*
- sync with a rsync daemon (eventually with a HTTP interface on top) and a local directory: *RsyncD*
  
These settings are represented by S3 classes in R. The list of methods follows below.


## RsyncL Connection

### Setting up the Connection

The first step of every `rsync` process is to initialize a rsync object. For
establishing a local connection following arguements are needed:

`from` defines the name of directory path of the file to be synced, not the file
itself. `to` specifies the destination directory.

```
con <- rsync::newRsync(from = "~/exampleFolder", to = "~/destinationFolder")
```


### Sending

`listFiles` takes the *rsyncL* object `con` as input and returns the objects
contained in the destination folder (`con$to`).

```
rsync::listFiles(con)
```

Sending a file is done with `sendFile()`. Input arguments are the *rsyncL* object as well as `fileName`.
Optional are the arguments `validate=TRUE` which validates, whether both file versions are exactely identical, if set to `TRUE` and `verbose=FALSE`, 
which gives out additional information about the process, if set to `TRUE`.

```
rsync::sendFile(con, fileName = "exampleFile.Rdata")
```
`sendFolder()` syncs the complete content of a folder between two local directories. `folder`specifies the name of the corresponding folder. Optional arguments are the same as in the `sendFile()` case.

```
rsync::sendFolder(con, folder = 'exampleFolder')
```

`sendObject()` syncs an object with a destination folder. It will create an
'Rdata' file on the fly. `obj` specifies the object from the working environment.
Optional arguments are as for `sendFile()`.

```
z <- 3
rsync::sendObject(con, obj = z)
```

### Deleting

`removeFile()` deletes an entry in the destination folder. `fileName` defines the name of the entry. 

```
rsync::removeFile(con, fileName = "z.Rdata")
```

`removeAllFiles()` deletes all entries in the destination folder of `con`.

```
rsync::removeAllFiles(con)
```

### Retrieving

`getFile()` can be used to retrieve entries from a directory. `con` refers again to the *rsyncL* object and `fileName` to the entry in `con$to` that shall be retrieved. Optional are the arguments `validate=TRUE`, which validates whether both file versions are exactely identical, if set to `TRUE` and `verbose=FALSE`, 
which gives out additional information about the process, if set to `TRUE`.

```
rsync::getFile(con, fileName)
```

`loadData()` takes the *rsyncL* object as well as `fileName`, a charater object in the directory of `con$to`, containing the name of the object that shall be loaded. The function is capable of loading any of the following file extensions into the working environment: '.Rdata', '.csv', '.json'

```
rsync::loadData(con, fileName = "x.json")
```

## RsyncD Connection

### Setting up the Connection
Analogously to the *rsyncL* connection, a *rsyncD* object needs to be created as the first step of the `rsync` process.
Therefore, call  `newRsync()` as follows: `from` is set to the working directory by default and specifies the local end of a rsync connection. Other local paths are possible.`host` specifies the adress of the rsync daemon. `name` refers to the server name and `password`intuetively to the server's password. 

```
con <- rsync::newRsync(from = getwd(),
                       host = 'rsync://user@example.de',
                       name = 'someFolder',
                       password  = 'password')
```

Besides the initial specification of the *rsyncD* object, the usage of the remaining functions are very similar to the case of *rsyncL*.


### Sending

`listFiles` takes the *rsyncD* object as input and returns objects, contained in the destination folder (`con$to`). `con$to`has automatically been contructed from the arguments `con$host` and `con$name`.

```
rsync::listFiles(con)
```
Sending a file is achieved via `sendFile()`. Input arguments are the *rsyncD* object as well as `fileName`, which is available in `con$from` and shall be synced to `con$to`.

```
rsync::sendFile(con, fileName = "exampleFile.Rdata")
```

`sendFolder()` syncs the complete content from a folder of a local directory (`con$from`) to a rsync daemon (`con$to`). `folder` specifies the name of the corresponding folder.

```
rsync::sendFolder(con, folder = 'exampleFolder')
```

`sendObject()` syncs an object from the working environment to a rsync daemon (`con$to`). It will create an
'Rdata' file on the fly. `obj` specifies the object from the working environment.

```
z <- 3
rsync::sendObject(con, obj = z)
```


### Deleting

`removeFile()` deletes an entry in the destination folder, of the rsync daemon. `fileName` defines the name of the entry. 

```
rsync::removeFile(con, fileName = "z.Rdata")
```

`removeAllFiles()` deletes all entries in the destination folder of `con`.

```
rsync::removeAllFiles(con)
```


### Retrieving

`getFile()` can be used to retrieve entries from a rsync daemon. `con` refers again to the *rsyncD* object and `fileName` to the entry that shall be retrieved.

```
rsync::getFile(con, fileName)
```

`loadData()` takes the *rsyncD* object as well as `fileName`, a charater object containing the name of the object that shall be loaded. 
The function is capable of loading any of the following file extensions into the working environment: '.Rdata', '.csv', '.json'

```
rsync::loadData(con, fileName = "x.json")
```
