include env_make
NS = docker-registry.poven.antillion.mil.uk:5000
VERSION ?= 2.7.1-1-GA

REPO = rundeck
NAME = rundeck
INSTANCE = default
SUDO_CMD = sudo

.PHONY: build push shell run start stop rm release

build:
	$(SUDO_CMD) docker build -t $(NS)/$(REPO):$(VERSION) .

push:
	$(SUDO_CMD) docker push $(NS)/$(REPO):$(VERSION)

push_docker:
	$(SUDO_CMD) docker tag -f $(NS)/$(REPO):$(VERSION) antillion/salt-master-docker:$(VERSION)
	$(SUDO_CMD) docker push antillion/salt-master-docker:$(VERSION)

shell:
	$(SUDO_CMD) docker run --rm --name $(NAME)-$(INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION) /bin/bash

run:
	echo "Note: to kill you'll need to Ctrl+Z and then issue: make kill"
	$(SUDO_CMD) docker run --rm --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

export:
	$(SUDO_CMD) docker save --output=$(NAME)_$(REPO)_$(VERSION).tar $(NS)/$(REPO):$(VERSION)

kill:
	$(SUDO_CMD) docker kill $(NAME)-$(INSTANCE)

start:
	$(SUDO_CMD) docker run -d --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

stop:
	$(SUDO_CMD) docker stop $(NAME)-$(INSTANCE)

rm:
	$(SUDO_CMD) docker rm $(NAME)-$(INSTANCE)

release: build
	make push -e VERSION=$(VERSION)

default: build
