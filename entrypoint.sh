#!/bin/sh
for I in profiles sites; do \
  mkdir -p /app/shared/$I
done

cp -rv /template/sites/* /app/shared/sites/

chown -R www-data:www-data /app/shared/*
chown -R www-data:www-data /app/config

# In case modules have changed, perform a database update
drush updb -y && drush cache-rebuild

# Startup Script
apache2-foreground
