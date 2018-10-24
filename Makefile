LOCAL_NAME=tensorflow_tools
VERSION=1.8.0
PUBLIC_NAME=tensorflow_tools
REPOSITORY=aryangold


.PHONY: all build tag release

all: build tag release

build:
	docker build -t $(LOCAL_NAME):$(VERSION) --rm .

tag: build
	docker tag $(LOCAL_NAME):$(VERSION) $(REPOSITORY)/$(PUBLIC_NAME):$(VERSION)

release: tag
	docker push $(REPOSITORY)/$(PUBLIC_NAME):$(VERSION)

