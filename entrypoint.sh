#!/bin/sh
for I in profiles sites; do \
  mkdir -p /app/shared/$I
done

cp -rv /template/sites/* /app/shared/sites/

chown -R www-data:www-data /app/shared/*
chown -R www-data:www-data /app/config

chmod -R 0775 /app/shared/sites/default/

# Startup Script
apache2-foreground
