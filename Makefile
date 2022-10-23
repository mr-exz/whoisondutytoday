DOCKER_IMAGE_NAME = whoisondutytoday
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

ifeq ("$(BRANCH)", "master")
	DOCKER_IMAGE_TAG = $(shell cat ./CHANGELOG.md | grep -e '^\#\# .*' | head -n 1 | cut -d' ' -f 2)
else
	DOCKER_IMAGE_TAG = $(shell cat ./CHANGELOG.md | grep -e '^\#\# .*' | head -n 1 | cut -d' ' -f 2)-${BRANCH}
endif

DOCKER_REGISTRY_URL = docker.io/mrexz

build:
	docker build --build-arg DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG} -t ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .

tag-latest:
ifeq ("$(BRANCH)", "master")
	docker tag ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:latest
endif

tag-latest-force:
	docker tag ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:latest


push:
	docker push ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
ifeq ("$(BRANCH)", "master")
	docker push ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:latest
endif

all: build tag-latest push