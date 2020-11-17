#!/bin/sh
for I in profiles sites; do \
  mkdir -p /app/shared/$I
done

cp -rv /template/sites/* /app/shared/sites/

chown -R www-data:www-data /app/shared/*
chown -R www-data:www-data /app/config

cd /opt/drupal/web && make update

# Startup Script
apache2-foreground
