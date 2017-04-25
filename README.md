docker-rsync
============
Copying data from an old storage solution to a new one is a common task for system administrators.

This containerized approach attempts to make this process a little easier.

# Prerequisites
* The docker host must have write permission to the destination mount.
* 1GB or more available RAM.
* 5GB or more available disk space

## Limitations

* **NFS** - Directories must be mounted with the option `nolock` as a true NFS server is not spawned.
* **Docker** - Must be run in privileged mode to allow mounting directories.



## Tested With:

- Rsync `3.1.2`
- Docker `1.9`,`1.10`,`1.12.1`
- CentOS `6.8`
- NFS `v3`

## Installation

```
git clone https://github.com/unixandmore/docker-sync.git

cd docker-sync
make build

```
## Running
* Required Values:
>* Old NAS name or IP
>* new NAS name or IP
>* Old vfs/share combination eg: */root_vdm_1/share_name*
>* New VFS/share combination
>* Old local mount point
>* New local mount point

```
docker run -it --rm --privileged docker_sync:master
```

### JSON Format
```
{
  "nas": {
    "old": {
      "name": ""
    },
    "new": {
      "name": ""
    }
  },
  "mounts" : {
    "FS_Name": {
      "old": {
        "remote": "",
        "local": ""
      },
      "new": {
        "remote": "",
        "local": ""
      }
    }
  }
}
```

#### Example

* Move a share called `data` from `nas1.example.com` to `nas2.example.com`

* Create a new `JSON` formatted file called `mydata.json` with the following contents:

```
{
  "nas": {
    "old": {
      "name": "nas1.example.com"
    },
    "new": {
      "name": "nas2.example.com"
    }
  },
  "mounts" : {
    "data": {
      "old": {
        "remote": "/root_vdm_1/data",
        "local": "/mnt/old_data"
      },
      "new": {
        "remote": "/PROD_DATA",
        "local": "/mnt/data"
      }
    }
  }
}
```

## TODO

- Create a script to generate a json file.
