[![Travis-CI Build Status](https://travis-ci.org//INWTlab/rsync.svg?branch=master)](https://travis-ci.org/INWTlab/rsync)


## RSync-Package of INWT

In this project we provide functionalites of Rsync for INWT project. 


## Why using Rsync:

....


## How to use Rsync:

Use the `rsync`function in the following way: 

```
rsync(from = "SyncTest/Testfile1.R", to = "SyncDestination/")
```

In order to use RSync with a server, credentials must be stored in the home directory under the folder `.rsync` and the file name `rsync.yaml`.
The `rsync.yaml` file needs to have the following structure:

```
hostURL: "rsync://example-url-of-host.de"
nameServer: "exampleServerName"
passwordServer:  "examplePassword1234"
urlServer: "https://url-to-Server.de"
```








