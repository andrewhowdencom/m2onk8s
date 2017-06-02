# Task runner

.PHONY: help build

.DEFAULT_GOAL := help

SHELL := /bin/bash

# http://stackoverflow.com/questions/1404796/how-to-get-the-latest-tag-name-in-current-branch-in-git
APP_VERSION := $(shell git describe --abbrev=0)

#PROJECT_NS   := m2onk8s-hackery-littleman-co
#CONTAINER_NS := m2onk8s-hackery-littleman-co
GIT_HASH     := $(shell git rev-parse --short HEAD)

ANSI_TITLE        := '\e[1;32m'
ANSI_CMD          := '\e[0;32m'
ANSI_TITLE        := '\e[0;33m'
ANSI_SUBTITLE     := '\e[0;37m'
ANSI_WARNING      := '\e[1;31m'
ANSI_OFF          := '\e[0m'

PATH_DOCS                := $(shell pwd)/docs
PATH_BUILD_CONFIGURATION := $(shell pwd)/build

TIMESTAMP := $(shell date "+%s")

help: ## Show this menu
	@echo -e $(ANSI_TITLE)m2onk8s-hackery-littleman-co$(ANSI_OFF)$(ANSI_SUBTITLE)" - Fucking around getting Magento2 up on Kubernetes "$(ANSI_OFF)
	@echo -e "\nUsage: $ make \$${COMMAND} \n"
	@echo -e "Requirements: php, composer, docker, git\n"
	@echo -e "Variables use the \$${VARIABLE} syntax, and are supplied as environment variables before the command. For example, \n"
	@echo -e "  \$$ VARIABLE="foo" make help\n"
	@echo -e $(ANSI_TITLE)Commands:$(ANSI_OFF)
	@grep -E '^[a-zA-Z_-%]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[32m%-30s\033[0m %s\n", $$1, $$2}'

container: ## ${NAME} | Builds a container. The only container is webserver, so you probably want "$ NAME=magento make container"
	docker build --tag gcr.io/littlemanco/m2onk8s:$(APP_VERSION) \
	    --file build/containers/${NAME}/Dockerfile \
	    .

app-dependencies: ## Installs the application dependencies (so, the application itself)
	cd app && \
	    composer install \
		--ignore-platform-reqs \
		--no-dev

app-enable-modules: ## Something I have to do for some reason
	cd app && \
	    php bin/magento module:enable -all

app-di: ## Builds the Magento DI configuration
	docker run -v $$(pwd):/tmp/ quay.io/littlemanco/apache-php:7.0.19-1_3 \
	    php /tmp/app/bin/magento setup:di:compile

fix-perms: ## Chanages the permissions to they're owned by the www-data user
	sudo chown -R 33:33 app
