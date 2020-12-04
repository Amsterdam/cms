.DEFAULT_GOAL := help

CONTAINER ?= drupal
package ?=
command ?= install

# PHONY prevents filenames being used as targets
.PHONY: help info rebuild status start stop restart build import_db shell

help: ## show this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

info: ## dump Makefile variables to screen
	@echo -e $(_MAKEFILE_VARIABLES)

build_nocache: ## Build the container by pulling the image from source instead from cache
	docker-compose build --pull --no-cache

build: ## build Docker Compose images
	docker-compose build

start: ## start single Docker Compose service in detached mode. Run make update after starting the container to flush Drupal cache
	docker-compose up

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

import_db: ## import postgres database. Usage: make DB_FILE=psql.gz import_db
ifdef DB_FILE
	## @docker-compose exec -T database dropdb --if-exists -e -U postgres cms
	@docker-compose exec -T database pg_restore -C --clean --no-acl --no-owner --username=postgres -d postgres < ${DB_FILE}
else
	@echo -e "No filename given for database source file"
endif

composer: ## Run composer command. Usage: make command=require package=composer/installers:1.9 composer. Run make composer to just install all dependencies
	${shell ./install_composer.sh}
	@COMPOSER_MEMORY_LIMIT=-1 php ./composer.phar ${command} ${package}

drupal_update: ## Update all Drupal packages and related dependencies. When upgrading Drupal's core major version, make sure to use the same major version reference in both Dockerfile and composer.json
	${call _composer, update drupal/core-* --with-all-dependencies}
