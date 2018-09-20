  
[![Travis-CI Build Status](https://travis-ci.org//INWTlab/rsync.svg?branch=master)](https://travis-ci.org/INWTlab/rsync)


## Rsync as R-Package

`rsync` is a open source file-copying tool that is freely available under the
GNU General Public License. This is an R package providing an API to rsync from
R.


## Why using rsync:

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

The rsync package can be downloaded and installed by running the following command from the R console:

```
devtools::install_github("INWTlab/rsync")
```

## Settings / Classes

We distinguish between three settings for which we use rsync:

- sync between local directories (`RsyncL`)
- sync with an rsync daemon and a local directory (`RsyncD`)
- sync with an rsync daemon (write only) and a local directory and reading using
  HTTP (`RsyncDHTTP`)
  
These settings are represented by S3 classes in R. The list of methods follows below.


## Methods


### RsyncL Connection

#### Setting up the Connection
The first step of every `rsync` process, is to establish a rsync object.
Depending on the type of object, different information is needed.
For establishing a local connection following arguements are needed:

`from`defines the name of directory path of the file to be synced, not the file itself.
`to` specifies the destination directory. The function returns a list object.

```
conObject <- rsync::rsyncL(from = "C:/exampleFolder/"
                           to = "C:/destinationFolder")
```

#### Listing Entries
`listEntries` takes the rsyncL object as input and gives out the objects contained in the destination folder (`conObject$to`)

```
rsync::listEntries(conObject)
```

#### Sending a File
Sending a file is easy. The file's directory is already defined in the rsyncL object `conObject`.
`sendFile()` takes two arguments as input: `conObject`and `file`. It then sends the specified file to `conObject$to`.

```
rsync::sendFile(conObject, file = "exampleFile.R")
```

#### Sending a Folder
`sendFolder()` syncs a complete folder between two local directories. `conObject` contains the information about the local connection type `rsyncL`.
`dirName`takes as input the path to the folder that shall be sent. `pattern` defines which files from the folder shall be synced.

```
rsync::sendFolder(conObject, dirName, pattern = "*.Rdata")
```
#### Sending an Object

`sendObject()` syncs an object with a destination folder.
`conObject`is of type rsyncL and contains the information on the destination location (`conObject$to`)
An exemplary object `z` shall be the object to be sent. It is taken as second input argument in `sendObject()`

```
z <- 3
rsync::sendObject(conObject, obj = z)
```

#### Deleting an Entry
`deleteEntry()` deletes an entry of the destination folder. 
`conObject` contains information on the  destination folder (`conObject$to`).
`entryName` defines the objects to be deleted. 

```
rsync::deleteEntry(conObject, entryName = "z.Rdata")
```
#### Deleting all Entries
`deleteAllEntries()` deltes all entries of the destination folder. 
`conObject` contains information on type of connection and destination folder (`conObject$to`).

```
rsync::deleteAllEntries(conObject)
```
#### Getting an Entry

`get()` prints out the content of `entryName` of a rsyncL directory `conObject$from`).
If `entryName` is a character the entry is saved there first. Then it is tried to load that file into R and return it from this function.
This is implemented for csv, json and Rdata files. `...` are passed to `download.file` which is only used in case `file` is not `NULL`.
   
```
rsync::get(conObject, entryName)
```

#### Validating the Sync

`rsync::rsyncSuccessful()` tests if the sync process was successful. It returns TRUE in this case, FALSE in every other case.

```
local  <- function(file) paste0(conObject$from, "/", file)
remote <- function(file) paste0(conObject$to, "/", file)

rsync::rsyncSuccessful(local("exampleFile.Rdata"), remote("exampleFile.Rdata"))
```





### RsyncDHTTP Connection 

#### Setting up the Connection
The first step of every `rsync` process, is to create a rsyncDHTTP object.
Depending on the type of object, different information is needed.
For a connection with a rsync HTTP server follwoing arguements are needed:

```
conObject <- rsync::rsyncDHTTP( host = "rsync://user@example.de",
                                name = "server123",
                                password = "r4nd0mPwd123",
                                url =  "https://serverAddress.de")
```

#### Listing Entries
`listEntries` takes the rsyncDHTTP object as input and gives out the objects available on the server (`conObject$host`)

```
rsync::listEntries(conObject)
```

#### Sending a File to a rsync HTTP server
With `sendFile()` it is possible to send a file from a local directory to a rsync HTTP server. 
`sendFile()` takes two arguments as input: `conObject`and `file`. `file` contains the name of the file and its path. It then sends the specified file to `conObject$host`.

```
rsync::sendFile(conObject, file = "C:/pathToFile/exampleFile.R")
```

#### Sending a Folder to a rsync HTTP server

`sendFolder()` allows to send a folder from a local directory to a rsync HTTP server. 
`dirName`takes as input the path to the folder that shall be sent. `pattern` defines which files from the folder shall be synced.
`conObject` contains the information on where the folder is sent. 


```
rsync::sendFolder(conObject, dirName, pattern = "*.Rdata")
```
#### Sending an Object to a rsync HTTP server

`sendObject()` syncs an object with a rsync HTTP server.
`conObject`is of type rsyncDHTTP and contains the information on the destination server (`conObject$host`)
An exemplary object `z` shall be the object to be sent. It is taken as second input argument in `sendObject()`

```
z <- 3
rsync::sendObject(conObject, obj = z)
```

#### Extracting a file from a rsync HTTP server
`extractFile` extracts a file `file` from the rsync HTTP server `conObject` and sends it to `to`.

```
rsync::extractFile(conObject, file, to)
```

#### Extracting a folder from a rsync HTTP server
`extractFolder` extracts a folder from the rsync HTTP server `conObject` and sends it to `to`.
Either a pattern is specified (`pattern`), which selects files or the optional argument `folder` is defined. 

```
rsync::extractFolder(conObject, to, folder = "")
```

#### Deleting an Entry
`deleteEntry()` deletes an entry on the rsync HTTP server.
`conObject` is of type rsyncDHTTP and contains information of the server.
`entryName` defines the objects to be deleted. 

```
rsync::deleteEntry(conObject, entryName)
```
#### Deleting all Entries
`deleteAllEntries()` deltes all entries on the rsync HTTP server. 
`conObject` is of type rsyncDHTTP and contains information of the server.

```
rsync::deleteAllEntries(conObject)
```

#### Getting an Entry

`get()` prints out the content of `entryName` of a rsync HTTP server.
If `entryName` is a character the entry is saved there first. Then it is tried to load that file into R and return it from this function.
This is implemented for csv, json and Rdata files. `...` are passed to `download.file` which is only used in case `file` is not `NULL`.
   
```
rsync::get(conObject, entryName)
```


#### Validating the Sync

`rsync::rsyncSuccessful()` tests if the sync process was successful. It returns TRUE in this case, FALSE in every other case.
`dir` in `local` specifies the local directory. 

```
local <- function(file) paste0(dir , "/", file)
remote <- function(file) paste0(conObject$url, file)

rsync::rsyncSuccessful(local("exampleFile.Rdata"), remote("exampleFile.Rdata"))
```


### RsyncD Connection 

#### Setting up the Connection
The first step of every `rsync` process, is to create a rsyncD object.
Depending on the type of object, different information is needed.
For a connection with a rsync deamon follwoing arguements are needed:

```
conObject <- rsync::rsyncD(host = "rsync://user@example.de",
                           name = "server123",
                           password = "r4nd0mPwd123")
```

#### Listing Entries 
`listEntries` takes the rsyncD object as input and gives out the objects of the rsync deamon (`conObject$host`)

```
rsync::listEntries(conObject)
```

#### Sending a File from a deamon to a local directory
With `sendFile()` it is possible to send a file from a rsync deamon to a local directory. 
`sendFile()` takes three arguments as input: `conObject` the rsync deamon object, `file`  the name of the file and `to` the local destination directory.

```
rsync::sendFile(conObject, file = "exampleFile.R", to = "C:/destinationDir/")
```

#### Sending a Folder from a deamon to a local directory

`sendFolder()` allows to send a folder from a rsync Deamon to a local directory.
`conObject` contains the information on the rsync deamon.
`dirName`takes as input of the destination path. `folder` is optional and can be used to specify a folder that shall be sent. 

```
rsync::sendFolder(conObject, dirName, folder = "")
```
#### Sending an Object from a deamon to a local directory

`sendObject()` syncs an object from a rsync deamon with a local directory.
`conObject`is of type rsyncD and contains the information on the rsyn deamon.
An exemplary object `z` shall be the object to be sent. It is taken as second input argument in `sendObject()`
`to` defines the local destination directory.
```
z <- 3
rsync::sendObject(conObject, obj = z, to)
```

#### Deleting an Entry
`deleteEntry()` deletes an entry on the rsync deamon.
`conObject` is of type rsyncD and contains information of the deamon.
`entryName` defines the objects to be deleted. 

```
rsync::deleteEntry(conObject, entryName)
```
#### Deleting all Entries
`deleteAllEntries()` deltes all entries on the rsync deamon. 
`conObject` is of type rsyncD and contains information of the deamon.

```
rsync::deleteAllEntries(conObject)
```

#### Getting an Entry

`get()` prints out the content of `entryName` of a rsync deamon.
If `entryName` is a character the entry is saved there first. Then it is tried to load that file into R and return it from this function.
This is implemented for csv, json and Rdata files. `...` are passed to `download.file` which is only used in case `file` is not `NULL`.
   
```
rsync::get(conObject, entryName)
```

#### Validating the Sync

`rsync::rsyncSuccessful()` tests if the sync process was successful. It returns TRUE in this case, FALSE in every other case.

```
local  <- function(file) paste0(conObject$host, "/", file)
remote <- function(file) paste0(dir, "/", file)

rsync::rsyncSuccessful(local("exampleFile.Rdata"), remote("exampleFile.Rdata"))
```






