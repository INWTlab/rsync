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

For using `rsync` locally use the following function:
```
rsync(from = "SyncTest/Testfile1.R", to = "SyncDestination/")
```
It takes two arguments, namely `from` which specifies the  source destination and `to`, which defines the final destination. This functions behaves more like an improved copy command. 


For using `rsync` remotely a set of functions is relevant:
The remote-version requires some preparation.Credentials regarding the remote server must be stored in a config file in a user's home directory.
Within the home directory a hidden folder must be created, following the name `.rsync`. Within this folder a file must be stored that is named `rsync.yaml`.

The `rsync.yaml` file needs to have the following structure, where the right side of the `:` must be replaced by the corresponding information of the user's server.

```
hostURL: "rsync://example-url-of-host.de"
nameServer: "exampleServerName"
passwordServer:  "examplePassword1234"
urlServer: "https://url-to-Server.de"
```








