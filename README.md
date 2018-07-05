## RSync-Package of INWT

In this project we provide functionalites of Rsync for INWT project. 


## Why using Rsync:

....


## How to use Rsync:

Use the `rsync`function in the following way: 

```
rsync( from = "SyncTest/Testfile1.R", to = "SyncDestination/")
```

In order to use RSync with a server, credentials must be stored within a `config.R` file.
The `config.R`file needs to have the following structure:

```
hostURL = "rsync://example-url-of-host.de"
nameServer = "exampleServerName"
passwordServer =  "examplePassword1234"
urlServer = "https://url-to-Server.de"
```

Store the `config.R`file in the .....-directory. 






