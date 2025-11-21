DOCKER_IMAGE_NAME = whoisondutytoday
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
COMMIT_SHA := $(shell git rev-parse --short HEAD)
VERSION := $(shell cat ./CHANGELOG.md | grep -e '^\#\# .*' | head -n 1 | cut -d' ' -f 2)

ifeq ("$(BRANCH)", "master")
	# Master branch: use version only
	DOCKER_IMAGE_TAG = $(VERSION)
else
	# Non-master branches: append branch and commit SHA
	DOCKER_IMAGE_TAG = $(VERSION)-${BRANCH}-$(COMMIT_SHA)
endif

DOCKER_REGISTRY_URL = docker.io/mrexz

build: ## Build docker image with bot inside.
	docker build --build-arg DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG} -t ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .

tag-latest: ## Tag image with latest (only if you in master branch).
ifeq ("$(BRANCH)", "master")
	docker tag ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:latest
endif

tag-latest-force: ## Tag image any way with latest tag.
	docker tag ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:latest

push: ## Publish image to docker registry.
	docker push ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
ifeq ("$(BRANCH)", "master")
	docker push ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:latest
endif

help: ## Display available targets in make.
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST)

all: build tag-latest push