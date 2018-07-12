
[![Travis-CI Build Status](https://travis-ci.org//INWTlab/rsync.svg?branch=master)](https://travis-ci.org/INWTlab/rsync)


## rsync-Package of INWT:

In this project we provide functionalites of rsync for INWT project.
rsync is a open source file-copying tool that is freely available under the GNU General Public License.
We built an R package around it in order to describe features of rsync as well as make use of automatic testing. 

## Why using rsync:

Rsync is a tool, which is used with Unix systems and allows efficient transferring and synchronizing of files across computer systems. It is widely used for makeing backups, copying files or mirroring. 
Working with Rsync offers nice benefits, as it is:
  - fast
  - works remotly and locally 
  - minimizes data transfer, as it only transfers the changes within the files 
  - supports copying links, devices, owners, groups, and permissions

For further information about the original source of Rsync, please see this link: https://rsync.samba.org/

## Features:
The rsync functionality can be used in two ways: 
  1) directely transferring / synchronizing files locally
     `rsync:` 
      
  2) transferring files from a local host to a remote host
    `rsync::...`
    `rsync::...`
    `rsync::...`
    `rsync::...`
    

## Installation:
The rsync package can be downloaded and installed by running the following command from within R:
```
source("https://github.com/INWTlab/rsync")  #NOCH ZU ÄNDERN (oder tar.gz Datei laden?)
```


## How to use Rsync:

#### Local
For using `rsync` locally, use the following function:
```
rsync(from = "SyncTest/Testfile1.R", to = "SyncDestination/")
```
It takes two arguments, namely `from` which specifies the  source destination and `to`, which defines the final destination. This functions behaves more like an improved copy command. 

#### Global

For using `rsync` remotely a preparational step is neccessary. Credentials regarding the remote server must be stored in a config file in a user's home directory.
Within the home directory a hidden folder must be created, following the name `.rsync`. Within this folder a file must be stored that is named `rsync.yaml`.

The `rsync.yaml` file needs to have the following structure, where the right side of the `:` in each row must be replaced by the corresponding information of the user's server.


```
hostURL: "rsync://example-url-of-host.de"
nameServer: "exampleServerName"
passwordServer:  "examplePassword1234"
urlServer: "https://url-to-Server.de"
```


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


`rsync::ls()` calls the objects in the rsync storage from the data base and returns them as a data frame. `db`
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

`rsync::sendObject()` Send an R object to db. This is a wrapper around \code{sendFile}
```
rsync::sendObject(db, obj, objName = as.character(substitute(obj)), ...)
```



`rsync::sendFolder()` Sends the content of a folder to a data base using \code{sendFile}
```
rsync::sendFolder(db, folder, ..., validate = TRUE, verbose = FALSE)
```

`rsync::get()` If \code{file} is a character the entry is saved there first. Then it is
   tried to load that file into R and return it from this function. This is
   implemented for csv, json and Rdata files. \code{...} are passed to
   \link{download.file} which is only used in case \code{file} is not
   \code{NULL}.
   
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





