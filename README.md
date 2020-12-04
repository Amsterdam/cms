# Drupal CMS for the Amsterdam data portal

This is the implementation of a headless CMS for the data portal of the Municipality of Amsterdam where articles, publications and other editorial content will be published and maintained.
This is based on the Drupal CMS enriched with Elasticsearch capabilities.

## Architecture

The CMS backend will be used by editors to publish the editorial content. The editorial content will be made available through the headless API of Drupal and integrated in the website [Data en informatie](https://data.amsterdam.nl) (the data portal).

## Setting up the CMS locally

Use the `Makefile` commands to spin up the containers. Run `make` to list the available commands. Note that, to have the CMS fully functional, both the database dump and the site's configuration need to be imported/available.

### Build the containers

Run the build command to spin up the database, drupal, imgproxy and elasticsearch containers:

```
make build
```

### Importing the database

A postgress database export can be imported in the running database container by executing the command

```
make DB_FILE=db.gz import_db
```

### Importing the configuration

An instance's configuration can be exported from `{{CMS_URL}}/admin/config/development/configuration/full/export`. The contents of that file should be unzipped into the `app/config` folder. Importing the configuration:

```
make import_config
```

---
__IMPORTANT__

After spinning up the containers, Drupal requires that the cache be cleared, so after importing the database or configuration or even after rebuilding the containers, make sure to run the update command to fix any broken references:

```
make update
```
---

## Updating or requiring modules

Drupal modules are not included in the repository's file structure, but instead should be handled by composer.
New modules can be required by running

```
make composer_require package=<package>
```

where `<package>` takes the form `foo/bar` or `foo/bar:1.0.0` or `foo/bar=1.0.0` or `"foo/bar 1.0.0"`.

Updating a module/package can be done by running

```
make composer_update package=<package>
```

## Updating Drupal core

The Drupal core version is handled by Composer. Updating the Drupal core to the latest stable version, can be accomplished by running

```
make composer_update
```

This wil update the main dependencies.

To upgrade the Drupal core major version, both the Docker image name in the `Dockerfile` and the dependency versions in `composer.json` need to be changed from `8` to `9`.
