DOCKER_IMAGE_NAME = whoisondutytoday
BRANCH = ${{ github.ref }}

ifeq ("$(BRANCH)", "master")
	DOCKER_IMAGE_TAG = $(shell cat ./CHANGELOG.md | grep -e '^\#\# .*' | head -n 1 | cut -d' ' -f 2)
else
	DOCKER_IMAGE_TAG = $(shell cat ./CHANGELOG.md | grep -e '^\#\# .*' | head -n 1 | cut -d' ' -f 2)-${BRANCH}
endif

DOCKER_REGISTRY_URL = docker.io/mrexz

build:
	docker build -t ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} .

tag-latest:
ifeq ("$(BRANCH)", "master")
	docker tag ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}:latest
endif

push:
	docker push ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
ifeq ("$(BRANCH)", "master")
	docker push ${DOCKER_REGISTRY_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}:latest
endif

all: build tag-latest push