commit_hash:=$$(git log --pretty=format:'%h' -n 1)
branch := $(shell git rev-parse --abbrev-ref HEAD)
build:
	@echo "Building a new Docker image based on the latest branch: $(branch)"
	@docker build -t docker_rsync:$(branch) .
