[![Travis-CI Build Status](https://travis-ci.org//INWTlab/rsync.svg?branch=master)](https://travis-ci.org/INWTlab/rsync)
[![Coverage Status](https://img.shields.io/codecov/c/github/INWTlab/rsync/master.svg)](https://codecov.io/github/INWTlab/rsync?branch=master)

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

Similar and very popular alternatives exist. E.g. in contrast to AWS S3 the
solution here:

- Is free,
- fast(er), if you stay in your local network,
- but, S3 provides versioning, which is very neat.
  
## Installation:

The rsync R package can be downloaded and installed by running the following
command from the R console:


```r
devtools::install_github("INWTlab/rsync")
```

Make sure you have the `rsync` command line tool available.


## Examples

You create a rsync configuration using:


```r
library(rsync)
dir.create("destination")
dir.create("source")
dest <- rsync(dest = "destination", src = "source")
dest
```

```
## Rsync server: 
##   dest: /home/sebastian/projects/rsync/destination
##   src: /home/sebastian/projects/rsync/source
##   password: NULL 
## Directory in destination:
## [1] name         lastModified size        
## <0 rows> (or 0-length row.names)
```

In the case of an rsync daemon you can also supply a password. The way you think
about transactions is that we have a destination folder with which we want to
interact. All methods provided by this package will always operate on the
destination. It will not change the source, in most cases. An exception is
`sendObject`, that will also create a file in source.


```r
x <- 1
y <- 2
sendObject(dest, x)
```

```
## Rsync server: 
##   dest: /home/sebastian/projects/rsync/destination
##   src: /home/sebastian/projects/rsync/source
##   password: NULL 
## Directory in destination:
##      name        lastModified size
## 1 x.Rdata 2019-02-28 12:30:51   61
```

```r
sendObject(dest, y)
```

```
## Rsync server: 
##   dest: /home/sebastian/projects/rsync/destination
##   src: /home/sebastian/projects/rsync/source
##   password: NULL 
## Directory in destination:
##      name        lastModified size
## 1 x.Rdata 2019-02-28 12:30:51   61
## 2 y.Rdata 2019-02-28 12:30:51   60
```

We can see that we have added two new files. These two files now exist in the
source directory and the destination. The following examples illustrate the core
features of the package:


```r
removeAllFiles(dest) # will not change source
```

```
## Rsync server: 
##   dest: /home/sebastian/projects/rsync/destination
##   src: /home/sebastian/projects/rsync/source
##   password: NULL 
## Directory in destination:
## [1] name         lastModified size        
## <0 rows> (or 0-length row.names)
```

```r
sendFile(dest, "x.Rdata") # so we can still send the files
```

```
## Rsync server: 
##   dest: /home/sebastian/projects/rsync/destination
##   src: /home/sebastian/projects/rsync/source
##   password: NULL 
## Directory in destination:
##      name        lastModified size
## 1 x.Rdata 2019-02-28 12:30:51   61
```

```r
removeAllFiles(src <- rsync("source")) # make the source a destination
```

```
## Rsync server: 
##   dest: /home/sebastian/projects/rsync/source
##   src: /home/sebastian/projects/rsync
##   password: NULL 
## Directory in destination:
## [1] name         lastModified size        
## <0 rows> (or 0-length row.names)
```

```r
getFile(dest, "x.Rdata")
```

```
## Rsync server: 
##   dest: /home/sebastian/projects/rsync/destination
##   src: /home/sebastian/projects/rsync/source
##   password: NULL 
## Directory in destination:
##      name        lastModified size
## 1 x.Rdata 2019-02-28 12:30:51   61
```

```r
src
```

```
## Rsync server: 
##   dest: /home/sebastian/projects/rsync/source
##   src: /home/sebastian/projects/rsync
##   password: NULL 
## Directory in destination:
##      name        lastModified size
## 1 x.Rdata 2019-02-28 12:30:51   61
```




