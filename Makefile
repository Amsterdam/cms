.DEFAULT_GOAL := help

CONTAINER ?= drupal
package ?= ""

define _composer
	@COMPOSER_MEMORY_LIMIT=-1 php ./composer.phar ${1} ${2}
endef

_do_import:
ifdef DB_FILE
	@docker-compose exec -T database pg_restore -C --clean --no-acl --no-owner -U postgres -d cms < ${DB_FILE}
else
	@echo -e "No filename given for database source file"
endif

# PHONY prevents filenames being used as targets
.PHONY: help info rebuild status start stop restart build import_db shell

help: ## show this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

info: ## dump Makefile variables to screen
	@echo -e $(_MAKEFILE_VARIABLES)

build: ## build Docker Compose images
	docker-compose build

start: ## start single Docker Compose service in detached mode
	docker-compose up -d

stop: ## stop Docker Compose
	docker-compose down --remove-orphans

restart: stop start status ## restart Docker Compose

status: ## show Docker Compose process list
	docker-compose ps

import_config: ## Import site configuration from ./app/config folder
	@docker-compose exec -T drupal drush config-import -y
	@docker-compose exec -T drupal drush cache-rebuild
	@docker-compose exec -T drupal drush uli | sed 's/default/localhost/'

update: ## Update the database and display a one time login link for user ID 1
	@docker-compose exec -T drupal drush updb -y
	@docker-compose exec -T drupal drush cache-rebuild
	@docker-compose exec -T drupal drush uli | sed 's/default/localhost/'

rebuild: stop build start status ## stop running containers, build and start them

shell: ## execute command on container. Usage: make CONTAINER=database shell
	docker-compose exec ${CONTAINER} sh

import_db: _do_import update ## import postgres database. Usage: make DB_FILE=psql.gz import_db

composer_install: ## Install all composer dependencies
ifneq ("$(wildcard composer.phar)","")
	${call _composer, "install" ${package}}
else
  ${shell ./install_composer.sh}
	${call _composer, "install" ${package}}
endif

composer_update: ## Install all composer dependencies
ifneq ("$(wildcard composer.phar)","")
	${call _composer, "update" ${package}}
else
  ${shell ./install_composer.sh}
	${call _composer, "update" ${package}}
endif

composer_require: ## Require a specific dependency. Usage: make composer_require package=composer/installers:1.9
ifneq ("$(wildcard composer.phar)","")
	${call _composer, "require" ${package}}
else
  ${shell ./install_composer.sh}
	${call _composer, "update" ${package}}
endif
