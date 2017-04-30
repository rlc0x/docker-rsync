# Create JSON file

The name of the file is **important** the script expects to find a file in /tmp that matches the SYSNAME value when calling the script.

* Required Values:
>* Old NAS name or IP
>* new NAS name or IP
>* Old vfs/share combination eg: */root_vdm_1/share_name*
>* New VFS/share combination
>* Old local mount point
>* New local mount point




## JSON Format
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

## JSON Example

Create a file for a system called `accounting` that uses a share called `data`

Values:

* file name: `accounting.json`
* old NAS name: `nas1.example.com`
* new NAS name: `nas2.example.com`
* file system identifier: `prod_data`
* old share data
>* remote: `/root_vdm_1/data`
>* local: `/mnt/old_data`
* new share data
>* remote: `/PROD_DATA`
>* local: `/mnt/data` 



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
    "prod_data": {
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
