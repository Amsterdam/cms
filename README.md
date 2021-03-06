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

After spinning importing a database or a set of configuration files, there can be a mismatch between the two and Drupal requires that the cache be cleared. When running into issues after importing the database or configuration, try to run the update command to fix any broken references:

```
make update
```
---

## Updating or requiring modules

Drupal modules are not included in the repository's file structure, but instead should be handled by composer.
New modules can be required by running

```
make composer command=require package=<package>
```

where `<package>` takes the form `foo/bar` or `foo/bar:1.0.0` or `foo/bar=1.0.0` or `"foo/bar 1.0.0"`.

Updating a module/package can be done by running

```
make composer command=update package=<package>
```

## Removing modules

Modules (or plugins) can have entries in the database and will need to be uninstalled in the CMS' UI before they are removed from the `composer.json` file.

## Updating Drupal core

The Drupal core version is handled by Composer. Updating the Drupal core to the latest stable (minor or patch) version can be accomplished by running

```
make drupal_update
```

## Upgrading Drupal core

To upgrade the Drupal core major version, a couple of steps need to be taken:

1. Change the Docker image name in the `Dockerfile`
2. Update the versions in `composer.json` of the `drupal/core-*` dependencies and run `make composer command=update`
3. Change the version reference in the `dataportaal.theme` file in the `themes/custom/dataportaal/templates` folder
