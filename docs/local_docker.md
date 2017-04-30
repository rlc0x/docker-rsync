# Creating a local Docker image

* Follow the steps in [Creating a JSON file](json_file.md) to build out the configuration file

* Create a Dockerfile

```
FROM rlc0x/docker-rsync
COPY sysname.json /tmp/sysname.json
```

* Build the local image

```
docker build -t sysname-rsync .
```
