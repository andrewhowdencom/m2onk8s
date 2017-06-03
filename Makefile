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

vcs-auth-setup: ## Unlocks the resources in version control, moves authentication files to their expected location
	git-crypt unlock
	cp auth.json ~/.composer/

compose-up: ## Brings up the docker compose environment
	cd deploy/docker-compose && \
	    docker-compose up -d

container-build: ## ${NAME} | Builds a container. The only container is webserver, so you probably want "$  NAME=magento make build-container"
	docker build --tag quay.io/littlemanco/${NAME}:$(APP_VERSION) \
	    --file build/containers/${NAME}/Dockerfile \
	    .
container-push: ## Pushes the container to prod.
	docker -- push quay.io/littlemanco/${NAME}:$(APP_VERSION)

app-dependencies: ## Installs the application dependencies (so, the application itself)
	cd app && \
	    composer install \
		--ignore-platform-reqs \
		--no-dev

app-install: unfuck-docker ## Installl the application within the docker-compose environment
	docker exec dockercompose_magento_1 \
	    su --shell=/bin/bash www-data --command=' \
		php /var/www/html/bin/magento setup:install \
		    --db-host="db" \
		    --db-name="magento" \
		    --db-user="magento" \
		    --db-password="thisisthemagentopassword" \
		    --db-prefix="" \
		    --admin-user="m2onk8s" \
		    --admin-password="m2onk8s" \
		    --admin-email="devnull@littleman.co" \
		    --admin-firstname="m2onk8s" \
		    --admin-lastname="developer" \
		    --base-url="http://m2onk8s.hackery.littleman.local" \
		    --language="en_GB" \
		    --timezone="UTC"'

app-enable-modules: ## Something I have to do for some reason
	cd app && \
	    php bin/magento module:enable -all

app-di: ## Builds the Magento DI configuration
	docker run -v $$(pwd):/tmp/ quay.io/littlemanco/apache-php:7.0.19-1_3 \
	    php /tmp/app/bin/magento setup:di:compile

app-static: ## Builds the themes
	docker run -v $$(pwd):/tmp/ quay.io/littlemanco/apache-php:7.0.19-1_3 \
	    php /tmp/app/bin/magento setup:static-content:deploy

unfuck-docker: ## Makes the required filesystem / permissions changes to allow executing in docker-compose
	sudo chown -R 33:33 \
	    app/var \
	    app/app/etc \
	    app/pub/media \
	    app/pub/static

fix-perms: ## ${TYPE} Chanages the permissions to they're owned by the appropriate user
	[ "${TYPE}" == "prod" ] && \
	    export ID="33" ||  \
	    export ID="$$(id -u)"; \
	sudo chown -R $${ID}:$${ID} app

clean: ## Cleans all the caches and things from the repo
	- rm -rf app/var/*
