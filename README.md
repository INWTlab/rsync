---
output:
  html_document: default
  pdf_document: default
---
  
# [![Travis-CI Build Status](https://travis-ci.org//INWTlab/rsync.svg?branch=master)](https://travis-ci.org/INWTlab/rsync)


## rsync-Package of INWT:

In this project we provide functionalites of rsync for INWT projects.
rsync is a open source file-copying tool that is freely available under the GNU General Public License.
We built an R package around it in order to use its features in R contexts as well as make use of automatic testing. 

## Why using rsync:

Rsync is a tool, which is used with Unix systems and allows efficient transferring and synchronizing of files across computer systems. It is widely used for makeing backups, copying files or mirroring. 
Working with Rsync offers nice benefits, as it is:
  - fast
  - works remotly and locally 
  - minimizes data transfer, as it only transfers the changes within the files 
  - supports copying links, devices, owners, groups, and permissions

For further information about the original source of rsync, please see this link: https://rsync.samba.org/

## Features:
The rsync functionality can be used in three settings:

It is great for synchronizing files between...
   1) local directories (`RsyncL`)
   
  2) an HTTP interface of an rsync daemon and a local directory (`RsyncDHTTP`)
  
  3) an rsync daemon and a local directory (`RsyncD`)
   

## Installation:
The rsync package can be downloaded and installed by running the following command from the R console:
```
source("https://github.com/INWTlab/rsync")  #NOCH ZU ÄNDERN (oder tar.gz Datei laden?)
```


## How to use Rsync:


### Connection RsyncL

#### Setting up the connection
The first step of every `rsync` process, is to establish a connection object.
Argument `type` specifies the type of connection - RsyncL, RsyncDHHTP or RsyncD.
Depending on the type, different information is needed.

`type = "RsyncL"`specifies synchronization between two local directories.
`from`defines the name of the file to be synced, including its directory path.
`to` specifies the destination directory. The function returns a list object.

```
conObject <- rsync::connection( type = "RsyncL",
                                from = "C:/exampleFolder/"
                                to = "C:/destinationFolder")
```

#### List Entries
`listEntries` takes the connection object as input and gives out the object contained in the destination folder (`conObject$to`)

```
rsync::listEntries(conObject)
```

#### Sending a File
Sending a file is easy. File origin and destination are already defined in the connection object `conObject`.
This poses the input for the `sendFile()`function.

```
rsync::sendFile(conObject)
```

#### Sending a Folder
`sendFolder()` syncs a complete folder between two local directories. `conObject` contains the information about its type.
`dirName`takes as input the path to the folder that shall be sent. `pattern` defines which files from the folder shall be synced.

```
rsync::sendFolder(conObject, dirName, pattern = "*.Rdata")
```
#### Sending an Object


`sendObject()` syncs an Object with a destination folder.
`conObject` contains the information about its type and the destination location (`conObject$to`)
An exemplary object `z` shall be the object to be sent. It is taken as second input argument in `sendObject()`

```
z <- 3
rsync::sendObject(serverTestingRsyncL, obj = z)
```

#### Deleting an Entry
`deleteEntry()` deletes an entry of the destination folder. 
`conObject` contains information on type of connection and destination folder (`conObject$to`).
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

### Connection RsyncDHTTP




### Connection RsyncD


##Old
### Global

#### Preparation

For using `rsync` remotely a preparational step is neccessary. Credentials regarding the remote server must be stored in a config file in a user's home directory.
Within the home directory a hidden folder must be created, following the name `.rsync`. Within this folder a file must be stored that is named `rsync.yaml`.

The `rsync.yaml` file needs to have the following structure, where the right side of the `:` in each row must be replaced by the corresponding information of the user's server.


```
hostURL: "rsync://example-url-of-host.de"
nameServer: "exampleServerName"
passwordServer:  "examplePassword1234"
urlServer: "https://url-to-Server.de"
```

#### Usage

The remote version of `rsync` makes use of multiple function:

`rsync::connection()` establishes a connection to the remote server. All arguments `host`, `name`, `password`, `url` are characters. This function must access the credentials information stored in the previously created config file `rsync.yaml`.
```
rsync::connection(host, name, password, url)
```
Example:
```
rsync::connection(
    host     = read_yaml("~/.rsync/rsync.yaml")[[1]],
    name     = read_yaml("~/.rsync/rsync.yaml")[[2]],
    password = read_yaml("~/.rsync/rsync.yaml")[[3]],
    url      = read_yaml("~/.rsync/rsync.yaml")[[4]]) 
```
Outout:
```
Rsync server: 
  host: rsync://example-url-of-host.de/
  name: exampleServerName
  password: ****
  url: https://url-to-Server.de/
```


`rsync::ls()` calls the objects in the rsync storage from the data base and returns them as a data frame.
```
rsync::ls(db)
```

`rsync::delete()` deletes an entry in the data base.
```
rsync::delete(db, entryName, verbose = FALSE)
```

`rsync::deleteAllEntries()` deletes all entries in the data base
```
rsync::deleteAllEntries(db, verbose = FALSE)
``` 

`rsync::sendFile()` sends a locally stored file to a data base. If validate is TRUE the hash-sum of the remote file is compared to the local version. A warning is issued should the differ.

```
rsync::sendFile(db, file, validate = TRUE, verbose = FALSE)
```


`rsync::rsyncFile()` syncs a (local) file to the server that is specified in the config file. 
```
rsync::rsyncFile(db, file, args)
```

`rsync::rsyncSuccessful()` tests if the sync process was successfull. It returns TRUE in this case, FALSE in every other case.
```
rsync::rsyncSuccessful(localFile, remoteFile)
```

`rsync::identical()` tests if two files are synced successfully. It returns TRUE in this case, FALSE in every other case.
```
rsync::identical(localFile, remoteFile)
```

`rsync::sendObject()` Send an R object to db. This is a wrapper around `sendFile`
```
rsync::sendObject(db, obj, objName = as.character(substitute(obj)), ...)
```



`rsync::sendFolder()` Sends the content of a folder to a data base using `sendFile`
```
rsync::sendFolder(db, folder, ..., validate = TRUE, verbose = FALSE)
```

`rsync::get()` If `file` is a character the entry is saved there first. Then it is
   tried to load that file into R and return it from this function. This is
   implemented for csv, json and Rdata files. `...` are passed to
   `download.file` which is only used in case `file` is not
   `NULL`.
   
```
rsync::get(db, entryName, file = NULL, ...)
```


`rsync::loadrdata()` loads a R data object
```
rsync::loadrdata(address)
```


`rsync::loadcsv()` loads a csv file
```
rsync::loadcsv(address)
```


`rsync::loadjson()` loads a json file
```
rsync::loadjson(address)
```


`rsync::print.RsyncServer()` prints the name of the RsyncServer object
```
rsync::print.RsyncServer(x)
```

`rsync::print.as.character.RsyncServer()` converts a RsynsServer object to a character
```
rsync::print.as.character.RsyncServer(x)
```





