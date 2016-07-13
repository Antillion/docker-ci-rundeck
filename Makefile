include env_make
NS = hub.docker.com
VERSION ?= 2.6.2-1-GA

REPO = ci-rundeck
NAME = salt-master
INSTANCE = default

.PHONY: build push shell run start stop rm release

build:
	sudo docker build -t $(NS)/$(REPO):$(VERSION) .

push:
	sudo docker push $(NS)/$(REPO):$(VERSION)

push_docker:
	sudo docker tag -f $(NS)/$(REPO):$(VERSION) antillion/salt-master-docker:$(VERSION)
	sudo docker push antillion/salt-master-docker:$(VERSION)

shell:
	sudo docker run --rm --name $(NAME)-$(INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION) /bin/bash

run:
	echo "Note: to kill you'll need to Ctrl+Z and then issue: make kill"
	sudo docker run --rm --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

kill:
	sudo docker kill $(NAME)-$(INSTANCE)

start:
	sudo docker run -d --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

stop:
	sudo docker stop $(NAME)-$(INSTANCE)

rm:
	sudo docker rm $(NAME)-$(INSTANCE)

release: build
	make push -e VERSION=$(VERSION)

default: build
