docker-rsync
============
Copying data from an old storage solution to a new one is a common task for Linux System Administrators.

This containerized approach attempts to make this process a little easier.

# Introduction

Use Docker and Rsync to break large amounts of NAS shares into manageable chunks that can then be spread over multiple Docker hosts.

Requires one or more JSON formatted files containing configuration information about the shares being moved.

# Installation

## From Dockerhub

```
docker pull rlc0x/docker-rsync:latest
```

## From Github

```
git clone https://github.com/rlc0x/docker-rsync.git

cd docker-rsync
make build

```




# Use

## Prerequisites
* The destination mount must exist, and allow the Docker host write permission.
* The docker host must have write permission to the destination mount and read permission from the source.
* JSON formatted file(s) that describes the NAS shares being moved or copied. See [Creating the JSON File](docs/json-file.md)


## Limitations

* **NFS** - Directories must be mounted with the option `nolock` as a true NFS server is not spawned.
* **Docker** - Must be run in privileged mode to allow mounting directories.

## Running

If no command values are supplied, the container will start in maintenance mode. This is a good way to test different config file combinations.

*Remember to map a directory for storing any files created in this image*

* Interactive
```
docker run -it --privileged -v $PWD:/src rlc0x/docker-rsync
```

 * Daemon
 ```
 docker run -id --privileged -v $PWD:/src rlc0x/docker-rsync
 ```

 Use `docker exec` to connect to the container.

 
* **Required Values:**
- **JSON Formatted file name**
- **Command Triplet** in the form of `SYSNAME:FS_IDENTIFIER:SLEEP`

* Create a  The name of this file will be used to run the container.

* Run the Docker container with the file mapped in as `/tmp/sysname.json`

```
docker run -id --privileged -v $PWD/sysname.json:/tmp/sysname.json rlc0x/docker-rsync:latest sysname:fs_identifier:0
```



# Tested With:

- Rsync `3.1.2`
- Docker `1.9`,`1.10`,`1.12.1`
- CentOS `6.8`
- NFS `v3`



====

## TODO

- Create a script to generate a json file.
