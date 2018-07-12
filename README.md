---
output:
  html_document: default
  pdf_document: default
---
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

##Features:
The rsync functionality can be used in two ways: 
  1) directely transferring / synchronizing files locally
     `rsync:` 
      
  2) transferring files from a local host to a remote host
    `rsync::...`
    `rsync::...`
    `rsync::...`
    `rsync::...`
    

##Installation:
The rsync package can be downloaded and installed by running the following command from within R:
```
source("https://github.com/INWTlab/rsync")  #NOCH ZU ÄNDERN
```


## How to use Rsync:



Use the `rsync`function in the following way: 

```
rsync(from = "SyncTest/Testfile1.R", to = "SyncDestination/")
```

In order to use rsync with a server, credentials must be stored in the home directory under the folder `.rsync` and the file name `rsync.yaml`.
The `rsync.yaml` file needs to have the following structure:

```
hostURL: "rsync://example-url-of-host.de"
nameServer: "exampleServerName"
passwordServer:  "examplePassword1234"
urlServer: "https://url-to-Server.de"
```








